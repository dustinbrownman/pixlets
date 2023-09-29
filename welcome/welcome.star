load("render.star", "render")
load("animation.star", "animation")

def main():
    text = render.WrappedText(
        content="Good morning, Dustin",
        linespacing=3,
        color="#099",
    )

    wrapper = render.Box(
        child=text,
        padding=1,
    )

    output = animate_in_from(
        child=wrapper,
        x=0,
        y=32,
    )

    return render.Root(
        child = output
    )

def animate_in_from(child, x=0, y=0):
    return animation.Transformation(
        child=child,
        duration = 70,
        fill_mode="backwards",
        delay = 0,
        keyframes = [
            animation.Keyframe(
                percentage = 0.0,
                transforms = [animation.Translate(x, y)],
                curve = "linear",
            ),
            animation.Keyframe(
                percentage = 1.0,
                transforms = [animation.Translate(0, 0)],
            ),
        ],
    )
