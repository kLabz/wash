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
dotpath = {}
imports = {}
assignments = {}

def extract_dotpath(node):
    if isinstance(node, ast.Attribute):
        return extract_dotpath(node.value) + "." + node.attr
    elif isinstance(node, ast.Name):
        return node.id
    else:
        return 'TODO'

def split_pack(class_name, cls):
    pack = []
    module = ""
    alias = class_name

    for d in cls.decorator_list:
        if isinstance(d, ast.Call) and d.func.id == "dotpath":
            alias = extract_dotpath(d.args[0]).replace(".", "_")

    i = 0
    parts = alias.split('_')
    for p in parts:
        if p == "" or not p.islower():
            module = alias[i:]
            break

        pack.append(p)
        i += len(p) + 1

    # pack__Something1_Something2_Impl_ can be considered to be pack.Something2
    if module.startswith("_") and module.endswith("_Impl_"):
        module = module[(module.find("_", 1)+1):-len("_Impl_")]

    for d in cls.decorator_list:
        if isinstance(d, ast.Name) and d.id == "noImportFrom":
            path = '.'.join(pack) + '.' + module
            i = ast.Import([ast.alias('.'.join(pack))])
            dotpath[path] = i
            return i

    pack.append(module.lower())
    return ast.ImportFrom('.'.join(pack), [ast.alias(alias)], 0)

def resolve_import(class_name, cls):
    if len(cls.bases) == 1:
        base = cls.bases[0].id
        if base == "wash_app_BaseApplication" or base == "wash_app_BaseWatchFace":
            i = split_pack(class_name, cls)
            if isinstance(i, ast.ImportFrom) and len(i.module.split('.')) == 1:
                i.module = 'wash.app.' + i.module
            return i

    if class_name.startswith("wash_"):
        return split_pack(class_name, cls)

    if class_name == "system":
        return ast.Import([ast.alias("wasp")])

    for d in cls.decorator_list:
        if isinstance(d, ast.Call) and d.func.id == "dotpath":
            return split_pack(class_name, cls)

    if class_name == "Lambda" or class_name == "HxOverrides":
        return ast.ImportFrom('wash.haxe', [ast.alias(class_name)], 0)

    if class_name.startswith("haxe_") or class_name.startswith("python_"):
        return ast.ImportFrom('wash.haxe', [ast.alias(class_name)], 0)

    if class_name.endswith("Icon") or class_name == "DownArrow" or class_name == "UpArrow" or class_name == "Knob":
        return ast.ImportFrom('wash.icon.' + class_name, [ast.alias(class_name)], 0)

    raise Exception("Cannot identify class " + class_name)

def resolve_module(i):
    if isinstance(i, ast.ImportFrom):
        return i.module
    elif isinstance(i, ast.Import):
        return i.names[0].name
    else:
        raise Exception('Expected an Import or ImportFrom instance')

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
            if isinstance(target.value, ast.Name):
                if not target.value.id in assignments:
                    assignments[target.value.id] = []
                assignments[target.value.id].append(node)
            else:
                alias = ".".join(extract_dotpath(target).split('.')[:-1])
                if not alias in assignments:
                    assignments[alias] = []
                assignments[alias].append(node)

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
            for d in cls.decorator_list:
                if isinstance(d, ast.Call) and d.func.id == "dotpath":
                    alias = extract_dotpath(d.args[0]) #.replace(".", "_")
                    if alias in assignments:
                        for assign in assignments[alias]:
                            for t in assign.targets:
                                t.value = ast.Name(alias.split('.')[-1], ast.Store())
                            self.walk(assign.value)
                            self.local_assigns.append(assign)

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

            if isinstance(node, ast.Attribute):
                dp = extract_dotpath(node)
                if dp in dotpath:
                    i = dotpath[dp]
                    if not i in self.local_imports:
                        self.local_imports.append(i)

    def write(self, output):
        mod = resolve_module(self.importdata).split('.')
        path = output / "/".join(mod[0:-1])
        try:
            os.makedirs(path)
        except:
            pass

        imports = []
        imports_hack = []

        for i in self.local_imports:
            imports.append(i)

            # if isinstance(i, ast.ImportFrom):
            #     imports.append(ast.Import([ast.alias(i.module)]))

            #     name = i.names[0].name
            #     module_name = i.module.split('.')[-1]

            #     imports_hack.append(
            #         ast.Assign(
            #             [ast.Name(name, ast.Store())],
            #             ast.Attribute(ast.Name(module_name, ast.Load()), name, ast.Load())
            #         )
            #     )
            # else:
            #     imports.append(i)


            # try:
            #     if i.module == "wasp" or i.module == "wash.datavault":
            #         imports.append(ast.Import([ast.alias(i.module)]))
            #     else:
            #         imports.append(i)
            # except:
            #     imports.append(i)

        for cls in self.classes:
            for d in cls.decorator_list:
                if isinstance(d, ast.Call) and d.func.id == "dotpath":
                    cls.decorator_list.remove(d)
            for d in cls.decorator_list:
                if isinstance(d, ast.Name) and d.id == "noImportFrom":
                    cls.decorator_list.remove(d)


        module = ast.Module(imports + imports_hack + self.classes + self.local_assigns)
        f = open(path / (mod[-1] + ".py"), "w")
        f.write(astunparse.unparse(module))
        f.close()

        # print(path / (mod[-1] + ".py"))
        # print(astunparse.unparse(module))
        # print("\n\n\n")


modules = {}
for class_name in classes:
    cls = classes[class_name]
    importdata = resolve_import(class_name, cls)
    module = resolve_module(importdata)

    try:
        moddata = modules[module]
    except:
        moddata = ModuleData(importdata)
        modules[module] = moddata

    moddata.add_class(class_name, cls)

output = Path(__file__).parent / '../wasp-os/wasp/'

# Clear previous output
shutil.rmtree(output / "wash", True)
try:
    os.remove(output / "wasp.py")
except:
    pass

# TODO: update manifest (boards/manifest_240x240.py)

for mod in modules:
    module = modules[mod]
    module.process()
    module.write(output)

