#version 450 core

// flat in uint tex_id;
in vec2 tex_pos;
uniform sampler2D tex;
// uniform sampler2D tex1;
// uniform sampler2D tex2;

out vec4 frag_color;

// vec2 coord;

void main() {
	// frag_color = vec4(1.0, 0.0, 1.0, 1.0);
	ivec2 tex_size = textureSize(tex, 0);
	frag_color = texture(tex, vec2(tex_pos.x / tex_size.x, tex_pos.y / tex_size.y));
	// if (tex_id == 0) {
	// 	ivec2 tex_size = textureSize(tex0, 0);
	// 	coord = vec2(
	// 		tex_coord.x / tex_size.x,
	// 		tex_coord.y / tex_size.y
	// 	);
	// 	frag_color = texture(tex0, coord);
	// }

	// if (tex_id == 1) {
	// 	ivec2 tex_size = textureSize(tex1, 0);
	// 	coord = vec2(
	// 		tex_coord.x / tex_size.x,
	// 		tex_coord.y / tex_size.y
	// 	);
	// 	frag_color = texture(tex1, coord);
	// }

	// if (tex_id == 2) {
	// 	ivec2 tex_size = textureSize(tex2, 0);
	// 	coord = vec2(
	// 		tex_coord.x / tex_size.x,
	// 		tex_coord.y / tex_size.y
	// 	);
	// 	frag_color = texture(tex2, coord);
	// }
}
