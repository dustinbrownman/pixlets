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

    output = animate(
        child=wrapper,
        x=0,
        y=32,
    )

    return render.Root(
        child = output
    )

def animate(child, x=0, y=0):
    return animation.Transformation(
        child=child,
        duration = 500,
        delay = 0,
        keyframes = [
            animation.Keyframe(
                percentage = 0.0,
                transforms = [animation.Translate(x, y)],
                curve = "ease_out",
            ),
            animation.Keyframe(
                percentage = 0.15,
                transforms = [animation.Translate(0, 0)],
            ),
        ],
    )
