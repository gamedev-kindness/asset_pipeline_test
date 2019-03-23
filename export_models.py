import bpy
import os
import sys
import traceback
import json

sys.path = [os.getcwd()] + sys.path  # Ensure exporter from this folder

TEST_SCENE_DIR = os.path.join(os.getcwd(), "blend/furniture")
EXPORTED_DIR = os.path.join(os.getcwd(), "furniture/data")

def export_escn(out_file, config):
    """Fake the export operator call"""
    import io_scene_godot
    io_scene_godot.export(out_file, config)

def main():
    dir_queue = list()
    dir_queue.append('.')
    model_list = "furniture/data/list.json"
    data = {}
    if os.path.exists(model_list):
        data = json.load(open(model_list, "r"))
    while dir_queue:
        dir_relpath = dir_queue.pop(0)

        # read config file if present, otherwise use default
        src_dir_path = os.path.join(TEST_SCENE_DIR, dir_relpath)
        if os.path.exists(os.path.join(src_dir_path, "config.json")):
            with open(os.path.join(src_dir_path, "config.json")) as config_file:
                config = json.load(config_file)
        else:
            config = {}

        # create exported to directory
        exported_dir_path = os.path.join(EXPORTED_DIR, dir_relpath)
        if not os.path.exists(exported_dir_path):
            os.makedirs(exported_dir_path)

        for item in os.listdir(os.path.join(TEST_SCENE_DIR, dir_relpath)):
            item_abspath = os.path.join(TEST_SCENE_DIR, dir_relpath, item)
            if os.path.isdir(item_abspath):
                # push dir into queue for later traversal
                dir_queue.append(os.path.join(dir_relpath, item))
            elif item_abspath.endswith('blend'):
                # export blend file
                print("---------")
                print("Exporting {}".format(os.path.abspath(item_abspath)))
                bpy.ops.wm.open_mainfile(filepath=item_abspath)
                objects = bpy.context.scene.objects
                for obj in objects:
                    if obj.parent == None and obj.type == "MESH":
                        for obj2 in objects:
                            obj2.select = False
                        obj.location = (0, 0, 0)
                        obj.select = True
                        bpy.context.scene.objects.active = obj
                        bpy.ops.object.select_grouped(type='CHILDREN_RECURSIVE')
                        obj.select = True
                        dn = item.replace('.blend', '')
                        dn = dn + "_" + str(obj.name).replace(" ", "_")
                        dn = dn + ".escn"
                        out_path = os.path.join(
                            EXPORTED_DIR,
                            dir_relpath,
                            dn
                            )
                        data[dn] = {"name": obj.name, "fspath": os.path.join("furniture/data", dir_relpath, dn), "path": "res://" + os.path.join("furniture/data", dir_relpath, dn)}
                        check_name = obj.name.lower()
                        cf = {
                                "desk": ["desk"],
                                "cofee-table": ["cofeetable", "tablecofee"],
                                "table": ["type_bed", "table"],
                                "armchair": ["armchair"],
                                "stool": ["stool"],
                                "chair": ["type_chair", "chair"],
                                "large-sofa": ["loungesofa", "bigsofa"],
                                "corner-sofa": ["sofacorner"],
                                "sofa": ["sofa"],
                                "bed": ["type_bed", "bedsignle"],
                                "bed-double": ["beddouble", "bedking"],
                                "bed-bunk": ["bedbunk"],
                                "bookcase": ["bookcase"],
				"closet": ["closet"],
                                "kitchen-sink": ["kitchensink"],
                                "bathroom-sink": ["bathroomsink"],
                                "bathroom-cabinet": ["bathroomcabinet"],
                                "bathroom-bathtub": ["bathtub"],
                                "bathroom-mirror": ["bathroommirror"],
                                "bathroom-shower": ["shower"],
                                "bathroom-toilet": ["toilet1", "toilet2"],
                                "kitchen-cabinet": ["type_kcabinet", "kitchencabinet"],
                                "kitchen-stove": ["kitchenstove"],
                                "kitchen-fridge": ["kitchenfridge"],
                                "kitchen-bar": ["kitchenbar"],
                                "kitchen-microwave": ["kitchenmicrowave"],
                                "kitchen-washer": ["washer"],
				"accessory": [
                                    "type_accessory", "floorlamp", "plant", "vase", "bear", "kitchencoffeemachine",
                                    "lamproundfloor", "lampsquarefloor", "pillowbottom",
                                    "pillowtop", "toilet_paper", "trashcan"
                                ],
                                "accessories_ceiling": ["type_accessories_ceiling", "lampsquareceiling"],
                                "separator": ["type_separator", "paneling"],
                                "wall": ["type_wall", "window"]
                        }
                        matched = False
                        for r in cf.keys():
                            for h in cf[r]:
                                if check_name.find(h) >= 0:
                                    matched = True
                                    break
                            if matched:
                                data[dn]["type"] = r
                                break

                        if not matched:
                            data[dn]["type"] = "other"
                        export_escn(out_path, config)
                        print("Exported to {}".format(os.path.abspath(out_path)))
        for k in data.keys():
            md = data[k]["fspath"]
            if not os.path.exists(md):
                del data[k]
        fd = open(model_list, "w")
        fd.write(json.dumps(data, sort_keys = True, indent = 4, separators = [',', ': ']))
        fd.close()


def run_with_abort(function):
    """Runs a function such that an abort causes blender to quit with an error
    code. Otherwise, even a failed script will allow the Makefile to continue
    running"""
    try:
        function()
    except:
        traceback.print_exc()
        exit(1)


if __name__ == "__main__":
    run_with_abort(main)
