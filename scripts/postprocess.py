#!/usr/bin/env python

# Resources:
# - https://docs.python.org/3/library/ast.html
# - https://github.com/simonpercivall/astunparse
#
# - https://svn.python.org/projects/python/trunk/Demo/parser/unparse.py
# - https://stackoverflow.com/questions/768634/parse-a-py-file-read-the-ast-modify-it-then-write-back-the-modified-source-c

import ast
import astunparse
import os
import shutil
from pathlib import Path

classes = {}
imports = {}
assignments = {}

def split_pack(class_name):
    pack = []
    module = ""
    alias = class_name

    i = 0
    parts = class_name.split('_')
    for p in parts:
        if p == "" or not p.islower():
            module = class_name[i:]
            break

        pack.append(p)
        i += len(p) + 1

    # pack__Something1_Something2_Impl_ can be considered to be pack.Something2
    if module.startswith("_") and module.endswith("_Impl_"):
        module = module[(module.find("_", 1)+1):-len("_Impl_")]

    pack.append(module.lower())
    return ast.ImportFrom('.'.join(pack), [ast.alias(alias)], 0)

def resolve_import(class_name, cls):
    if len(cls.bases) == 1:
        base = cls.bases[0].id
        if base == "wash_app_BaseApplication" or base == "wash_app_BaseWatchFace":
            i = split_pack(class_name)
            if len(i.module.split('.')) == 1:
                i.module = 'wash.app.' + i.module
            return i

    if class_name.startswith("wash_"):
        return split_pack(class_name)

    if class_name == "DataVault":
        return ast.ImportFrom('wash.datavault', [ast.alias(class_name)], 0)

    if class_name == "Manager" or class_name == "Wasp" or class_name == "system":
        return ast.ImportFrom('wasp', [ast.alias(class_name)], 0)

    if class_name == "Lambda" or class_name == "HxOverrides":
        return ast.ImportFrom('wash.haxe', [ast.alias(class_name)], 0)

    if class_name.startswith("haxe_") or class_name.startswith("python_"):
        return ast.ImportFrom('wash.haxe', [ast.alias(class_name)], 0)

    if class_name.endswith("Icon") or class_name == "DownArrow" or class_name == "UpArrow" or class_name == "Knob":
        return ast.ImportFrom('wash.icon.' + class_name, [ast.alias(class_name)], 0)

    raise Exception("Cannot identify class " + class_name)


path = Path(__file__).parent / '../.tmp/wasp.py'
wasp_py = open(path, 'r')
wasp_ast = ast.parse(wasp_py.read())
wasp_py.close()

for node in wasp_ast.body:
    # Each ClassDef will generate its own module
    if isinstance(node, ast.ClassDef):
        classes[node.name] = node
        i = resolve_import(node.name, node)
        if i:
            imports[node.name] = i

    # Store import expressions in imports dict, to later dispatch them where
    # necessary
    elif isinstance(node, ast.Import) or isinstance(node, ast.ImportFrom):
        for alias in node.names:
            if not alias.asname:
                imports[alias.name] = node
            else:
                imports[alias.asname] = node

    # Store static var initialization as a dict, so each class (module) can
    # retrieve its statics
    elif isinstance(node, ast.Assign):
        for target in node.targets:
            if not target.value.id in assignments:
                assignments[target.value.id] = []
            assignments[target.value.id].append(node)

    # This is not happening atm, but maybe haxe will generate other top level
    # statements in some cases?
    else:
        print('Warning: node type ' + node.__class__.__name__ + ' is not handled')

class ModuleData:
    def __init__(self,importdata):
        self.importdata = importdata
        self.local_imports = []
        self.local_assigns = []
        self.classes = []
        self.class_names = []

    def add_class(self, class_name, cls):
        self.class_names.append(class_name)
        self.classes.append(cls)

    def process(self):
        for cls in self.classes:
            self.walk(cls)

        for cls in self.class_names:
            if cls in assignments:
                for assign in assignments[cls]:
                    self.walk(assign.value)
                    self.local_assigns.append(assign)

    def walk(self, expr):
        nodes = [node for node in ast.walk(expr)]
        for node in nodes:
            if isinstance(node, ast.Name):
                if node.id not in self.class_names and node.id in imports:
                    i = imports[node.id]
                    if not i in self.local_imports:
                        self.local_imports.append(i)

    def write(self, output):
        mod = self.importdata.module.split('.')
        path = output / "/".join(mod[0:-1])
        try:
            os.makedirs(path)
        except:
            pass

        module = ast.Module(self.local_imports + self.classes + self.local_assigns)
        f = open(path / (mod[-1] + ".py"), "w")
        f.write(astunparse.unparse(module))
        f.close()


modules = {}
for class_name in classes:
    cls = classes[class_name]
    importdata = resolve_import(class_name, cls)

    try:
        moddata = modules[importdata.module]
    except:
        moddata = ModuleData(importdata)
        modules[importdata.module] = moddata

    moddata.add_class(class_name, cls)

output = Path(__file__).parent / '../wasp-os/wasp/'

# Clear previous output
shutil.rmtree(output / "wash", True)
try:
    os.remove(output / "wasp.py")
except:
    pass

for mod in modules:
    module = modules[mod]
    module.process()
    module.write(output)

