shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0; // Controla el avance de la transición
uniform float pixel_size = 8.0; // Tamaño de los píxeles (más grande = más pixelado)
uniform sampler2D noise_tex : source_color; // Textura de ruido (puede ser Perlin o simplex)

void fragment() {
    vec2 uv = SCREEN_UV;

    // Simulamos un efecto de pixelado agrupando coordenadas UV
    vec2 pixelated_uv = floor(uv * pixel_size) / pixel_size;

    // Tomamos el ruido en esas coordenadas
    float noise_value = texture(noise_tex, pixelated_uv).r;

    // La pantalla se "disuelve" según el valor del ruido y el progreso
    if (noise_value < progress) {
        // Mostrar color de transición (negro, blanco, o cualquier color)
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        // Transparente (muestra el contenido debajo)
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    }
	// THX CHATGPT <3
}