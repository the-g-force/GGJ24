shader_type canvas_item;

uniform vec4 from : source_color = vec4(1, 0, 0, 1);
uniform vec4 to : source_color = vec4(1, 0, 1, 1);

void fragment() {
	COLOR = vec4(
		from * pow(length(UV), 2.0) + to * (1.0 - pow(length(UV), 2.0))
	);
}
