#!/usr/bin/env python3
"""Generate DevHardware.xcodeproj/project.pbxproj for an iOS device build."""
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SRC = "DevHardware"
PROJECT_DIR = ROOT / "DevHardware.xcodeproj"


def uid(name: str) -> str:
    return hashlib.md5(name.encode()).hexdigest()[:24].upper()


def swift_files():
    return sorted(p.relative_to(ROOT / SRC).as_posix() for p in (ROOT / SRC).rglob("*.swift"))


def build_group(prefix: str, files, refs, lines):
    """Emit PBXGroup entries mirroring the directory tree; return child ids of this level."""
    children = []
    dirs = sorted({f.split("/")[0] for f in files if "/" in f})
    for d in dirs:
        sub = [f.split("/", 1)[1] for f in files if f.startswith(d + "/")]
        gid = uid("group:" + prefix + d)
        kids = build_group(prefix + d + "/", sub, refs, lines)
        body = "\n".join(f"\t\t\t\t{k}," for k in kids)
        lines.append(
            f"\t\t{gid} /* {d} */ = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n{body}\n\t\t\t);\n"
            f"\t\t\tpath = {d};\n\t\t\tsourceTree = \"<group>\";\n\t\t}};"
        )
        children.append(gid)
    for f in files:
        if "/" not in f:
            children.append(refs[prefix + f])
    return children


def generate() -> str:
    files = swift_files()
    refs = {f: uid("fileref:" + f) for f in files}
    builds = {f: uid("build:" + f) for f in files}
    plist_ref = uid("fileref:Info.plist")
    product_ref = uid("product")
    project_id, target_id = uid("project"), uid("target")
    main_group, src_group, products_group = uid("maingroup"), uid("srcgroup"), uid("productsgroup")
    sources_phase, frameworks_phase, resources_phase = uid("sources"), uid("frameworks"), uid("resources")
    proj_cfg_list, tgt_cfg_list = uid("projcfglist"), uid("tgtcfglist")
    proj_debug, proj_release = uid("projdebug"), uid("projrelease")
    tgt_debug, tgt_release = uid("tgtdebug"), uid("tgtrelease")

    sub_lines = []
    top_children = build_group("", files, refs, sub_lines)
    top_children.append(plist_ref)
    src_body = "\n".join(f"\t\t\t\t{c}," for c in top_children)

    out = ["// !$*UTF8*$!", "{", "\tarchiveVersion = 1;", "\tclasses = {", "\t};", "\tobjectVersion = 56;", "\tobjects = {", ""]
    out.append("/* Begin PBXBuildFile section */")
    for f in files:
        out.append(f"\t\t{builds[f]} /* {Path(f).name} in Sources */ = {{isa = PBXBuildFile; fileRef = {refs[f]} /* {Path(f).name} */; }};")
    out += ["/* End PBXBuildFile section */", "", "/* Begin PBXFileReference section */"]
    for f in files:
        out.append(f"\t\t{refs[f]} /* {Path(f).name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {Path(f).name}; sourceTree = \"<group>\"; }};")
    out.append(f"\t\t{plist_ref} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = \"<group>\"; }};")
    out.append(f"\t\t{product_ref} /* DevHardware.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = DevHardware.app; sourceTree = BUILT_PRODUCTS_DIR; }};")
    out += ["/* End PBXFileReference section */", "", "/* Begin PBXFrameworksBuildPhase section */",
            f"\t\t{frameworks_phase} /* Frameworks */ = {{\n\t\t\tisa = PBXFrameworksBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};",
            "/* End PBXFrameworksBuildPhase section */", "", "/* Begin PBXGroup section */"]
    out += sub_lines
    out.append(f"\t\t{src_group} /* {SRC} */ = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n{src_body}\n\t\t\t);\n\t\t\tpath = {SRC};\n\t\t\tsourceTree = \"<group>\";\n\t\t}};")
    out.append(f"\t\t{products_group} /* Products */ = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t{product_ref},\n\t\t\t);\n\t\t\tname = Products;\n\t\t\tsourceTree = \"<group>\";\n\t\t}};")
    out.append(f"\t\t{main_group} = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t{src_group},\n\t\t\t\t{products_group},\n\t\t\t);\n\t\t\tsourceTree = \"<group>\";\n\t\t}};")
    out += ["/* End PBXGroup section */", "", "/* Begin PBXNativeTarget section */",
            f"\t\t{target_id} /* DevHardware */ = {{\n\t\t\tisa = PBXNativeTarget;\n\t\t\tbuildConfigurationList = {tgt_cfg_list};\n\t\t\tbuildPhases = (\n\t\t\t\t{sources_phase},\n\t\t\t\t{frameworks_phase},\n\t\t\t\t{resources_phase},\n\t\t\t);\n\t\t\tbuildRules = (\n\t\t\t);\n\t\t\tdependencies = (\n\t\t\t);\n\t\t\tname = DevHardware;\n\t\t\tproductName = DevHardware;\n\t\t\tproductReference = {product_ref};\n\t\t\tproductType = \"com.apple.product-type.application\";\n\t\t}};",
            "/* End PBXNativeTarget section */", "", "/* Begin PBXProject section */",
            f"\t\t{project_id} /* Project object */ = {{\n\t\t\tisa = PBXProject;\n\t\t\tattributes = {{\n\t\t\t\tBuildIndependentTargetsInParallel = 1;\n\t\t\t\tLastUpgradeCheck = 1500;\n\t\t\t}};\n\t\t\tbuildConfigurationList = {proj_cfg_list};\n\t\t\tcompatibilityVersion = \"Xcode 14.0\";\n\t\t\tdevelopmentRegion = en;\n\t\t\thasScannedForEncodings = 0;\n\t\t\tknownRegions = (\n\t\t\t\ten,\n\t\t\t\tBase,\n\t\t\t);\n\t\t\tmainGroup = {main_group};\n\t\t\tproductRefGroup = {products_group};\n\t\t\tprojectDirPath = \"\";\n\t\t\tprojectRoot = \"\";\n\t\t\ttargets = (\n\t\t\t\t{target_id},\n\t\t\t);\n\t\t}};",
            "/* End PBXProject section */", "", "/* Begin PBXResourcesBuildPhase section */",
            f"\t\t{resources_phase} /* Resources */ = {{\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};",
            "/* End PBXResourcesBuildPhase section */", "", "/* Begin PBXSourcesBuildPhase section */"]
    build_body = "\n".join(f"\t\t\t\t{builds[f]} /* {Path(f).name} in Sources */," for f in files)
    out.append(f"\t\t{sources_phase} /* Sources */ = {{\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n{build_body}\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};")
    out += ["/* End PBXSourcesBuildPhase section */", "", "/* Begin XCBuildConfiguration section */"]

    def cfg(cid, name, settings):
        body = "\n".join(f"\t\t\t\t{k} = {v};" for k, v in settings.items())
        return f"\t\t{cid} /* {name} */ = {{\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {{\n{body}\n\t\t\t}};\n\t\t\tname = {name};\n\t\t}};"

    common = {
        "ALWAYS_SEARCH_USER_PATHS": "NO",
        "ARCHS": "arm64",
        "CLANG_ENABLE_MODULES": "YES",
        "IPHONEOS_DEPLOYMENT_TARGET": "16.0",
        "SDKROOT": "iphoneos",
        "SWIFT_VERSION": "5.0",
        "TARGETED_DEVICE_FAMILY": '"1,2"',
    }
    out.append(cfg(proj_debug, "Debug", {**common, "ONLY_ACTIVE_ARCH": "YES", "SWIFT_OPTIMIZATION_LEVEL": '"-Onone"', "DEBUG_INFORMATION_FORMAT": "dwarf"}))
    out.append(cfg(proj_release, "Release", {**common, "SWIFT_COMPILATION_MODE": "wholemodule", "SWIFT_OPTIMIZATION_LEVEL": '"-O"', "DEBUG_INFORMATION_FORMAT": '"dwarf-with-dsym"', "VALIDATE_PRODUCT": "YES"}))
    target_settings = {
        "CODE_SIGN_STYLE": "Automatic",
        "CURRENT_PROJECT_VERSION": "1",
        "GENERATE_INFOPLIST_FILE": "NO",
        "INFOPLIST_FILE": f"{SRC}/Info.plist",
        "LD_RUNPATH_SEARCH_PATHS": '"$(inherited) @executable_path/Frameworks"',
        "MARKETING_VERSION": "1.0",
        "PRODUCT_BUNDLE_IDENTIFIER": "com.ace4youblade.DevHardware",
        "PRODUCT_NAME": '"$(TARGET_NAME)"',
    }
    out.append(cfg(tgt_debug, "Debug", target_settings))
    out.append(cfg(tgt_release, "Release", target_settings))
    out += ["/* End XCBuildConfiguration section */", "", "/* Begin XCConfigurationList section */"]
    for lid, label, dbg, rel in ((proj_cfg_list, 'PBXProject "DevHardware"', proj_debug, proj_release),
                                 (tgt_cfg_list, 'PBXNativeTarget "DevHardware"', tgt_debug, tgt_release)):
        out.append(f"\t\t{lid} /* Build configuration list for {label} */ = {{\n\t\t\tisa = XCConfigurationList;\n\t\t\tbuildConfigurations = (\n\t\t\t\t{dbg},\n\t\t\t\t{rel},\n\t\t\t);\n\t\t\tdefaultConfigurationIsVisible = 0;\n\t\t\tdefaultConfigurationName = Release;\n\t\t}};")
    out += ["/* End XCConfigurationList section */", "\t};", f"\trootObject = {project_id} /* Project object */;", "}", ""]
    return "\n".join(out)


if __name__ == "__main__":
    PROJECT_DIR.mkdir(exist_ok=True)
    (PROJECT_DIR / "project.pbxproj").write_text(generate(), encoding="utf-8")
    print("wrote", PROJECT_DIR / "project.pbxproj")
