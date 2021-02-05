import os
import bpy

bl_info = {
    "name": "Export animation frames as mesh files",
    "category": "Import-Export",
    "blender": (2, 90, 0),
    "location": "File > Export",
}


class frameExportMesh(bpy.types.Operator):
    """Export animation frames as mesh files."""
    bl_idname = "frame.export_mesh"
    bl_label = "Export frames as mesh files"
    bl_options = {'REGISTER'}

    def _get_camera(self, context):
        # TEST ! context = bpy.context
        camera = context.scene.camera
        render = context.scene.render

        # Get the two components to calculate M
        modelview_matrix = camera.matrix_world.inverted()
        projection_matrix = camera.calc_matrix_camera(
            # bpy.data.scenes["Scene"].view_layers["RenderLayer"].depsgraph,
            context.scene.view_layers[0].depsgraph,
            x=render.resolution_x,
            y=render.resolution_y,
            scale_x=render.pixel_aspect_x,
            scale_y=render.pixel_aspect_y,
        )

        # print(projection_matrix * modelview_matrix)
        # Compute P’ = M * P
        return projection_matrix @ modelview_matrix

    def execute(self, context):
        the_path = bpy.path.abspath('/tmp')
        scene = context.scene

        for frame in range(scene.frame_start, scene.frame_end):
            scene.frame_set(frame)

            # To rename a scene, just hit F2 on it
            fname = f"{scene.name}_{scene.frame_current:06}.ply"

            # https://docs.blender.org/api/current/bpy.ops.export_mesh.html
            # https://developer.blender.org/diffusion/BA/browse/master/io_mesh_ply/export_ply.py
            bpy.ops.export_mesh.ply(filepath=os.path.join(the_path, fname),
                                    use_ascii=True, use_normals=True)

            fname = f"{scene.name}_{scene.frame_current:06}.cam"
            matrix = self._get_camera(context)

            with open(os.path.join(the_path, fname), "w") as fout:
                for i in range(4):
                    fout.write(f"{matrix[i][:]}\n")

        return {'FINISHED'}


def menu_draw(self, context):
    self.layout.operator("frame.export_mesh")


def register():
    bpy.utils.register_class(frameExportMesh)
    bpy.types.TOPBAR_MT_file_export.append(menu_draw)


def unregister():
    bpy.utils.unregister_class(frameExportMesh)
    bpy.types.TOPBAR_MT_file_export.remove(menu_draw)


if __name__ == "__main__":
    register()
