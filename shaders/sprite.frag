#version 450 core

// flat in uint tex_id;
in vec2 tex_pos;
uniform sampler2D tex;

out vec4 frag_color;

void main() {
	ivec2 tex_size = textureSize(tex, 0);
	frag_color = texture(tex, vec2(tex_pos.x / tex_size.x, tex_pos.y / tex_size.y));
}
