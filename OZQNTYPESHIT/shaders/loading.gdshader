shader_type canvas_item;

// 每个小圆的半径
uniform float radius : hint_range(0.01, 0.2) = 0.05;
// 小圆组成的环的半径
uniform float ring_radius : hint_range(0.1, 1.0) = 0.35;
// 环绕速度，越大旋转越快
uniform float speed : hint_range(0.1, 10.0) = 1.0;
// 圆圈的数量
uniform int count : hint_range(1, 32) = 9;
// 控制亮度衰减的指数，越大“尾巴”越短
uniform float fade_power : hint_range(1.0, 10.0) = 0.2;
// 圆圈颜色（RGB），默认白色
uniform vec4 circle_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    // 将 UV 居中，并放大为 [-1, 1] 区域
    vec2 uv = (UV - vec2(0.5)) * 2.0;
    float alpha = 0.0;
    // 当前时间的“头部”位置（以浮点形式在 count 之间循环）
    float head = fract(TIME * speed) * float(count);

    // 遍历每个圆圈
    for (int i = 0; i < count; i++) {
        // 计算当前圆点的角度（均匀分布在圆环上）
        float angle = float(i) * 2.0 * PI / float(count);
        // 当前圆点在环上的坐标
        vec2 center = vec2(cos(angle), sin(angle)) * ring_radius;
        // 计算像素到该圆心的距离
        float dist = distance(uv, center);
        // 使用 smoothstep 判断是否落在圆内部，得到圆形图案（边缘平滑）
        float circle = smoothstep(radius, radius - 0.01, dist);
        // 计算当前点与头部之间的距离（取模以实现环绕）
        float offset = mod(float(i) - head + float(count), float(count));
        // 距离越远越暗，指数衰减控制“尾巴长短”
        float fade = 1.0 - exp(-fade_power * (1.0 - offset / float(count)));
        // 反转，让 fade 趋近 0 时更透明
        fade = 1.0 - fade;
        // 将该圆点贡献的透明度叠加到最终输出
        alpha += circle * fade;
    }

    // 输出最终颜色，RGB 为设定颜色，透明度为叠加结果
    COLOR = vec4(circle_color.rgb, alpha * circle_color.a);
}
