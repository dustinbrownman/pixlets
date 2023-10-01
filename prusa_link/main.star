load("render.star", "render")
load("animation.star", "animation")
load("math.star", "math")
load("time.star", "time")
load("humanize.star", "humanize")
load("encoding/base64.star", "base64")

ANIMATION_DURATION = 40
PROGRESS_BAR_WIDTH = 62

def main(config):
    printer_status = config.get("printer_status", "")
    job_name = config.get("job_name", "")
    progress = float(config.get("progress", "0.0"))
    elapsed = config.get("elapsed", "")
    remaining = config.get("remaining", "")

    if printer_status == "Offline":
        return offline()

    if printer_status == "Operational":
        return idle()

    if printer_status != "Printing":
        return []

    marquee = render.Box(
        height = 10,
        child = render.Marquee(
            width = 64,
            offset_start = 0,
            child = render.Text(job_name)
        )
    )

    progress_cursor = render.Box(
        width = 1,
        height = 8,
        color = "#ff7e25",
    )

    progress_bar = render.Box(
        width = 1,
        height = 8,
        color = "#ff7e2555",
    )

    percent_text = render.Padding(
        child = render.Text(
            content = humanize.ftoa(progress * 100, 0) + "%",
            color = "#ff7e25",
        ),
        pad = (1, 0, 0, 0),
    )

    combo_progress_bar = render.Stack(
        children = [
            animate_progress_bar(progress, progress_bar),
            animate_progress_cursor(progress, progress_cursor),
            percent_text,
        ]
    )

    temp_text = render.Text(
        content = "200°C",
        color = "#ff7e25",
    )

    remaining_text = render.Text(
        content = remaining + " left",
        font = "CG-pixel-3x5-mono",
        height = 5,
    )

    elapsed_text = render.Text(
        content = elapsed + " done",
        font = "CG-pixel-3x5-mono",
        height = 5,
    )

    scroll_text_stack = render.Stack(
        children = [
            up_and_out(center(elapsed_text), 40),
            up_from_bottom(center(remaining_text), 40),
        ],
    )

    output = render.Column(
        children = [
            marquee,
            combo_progress_bar,
            scroll_text_stack,
        ],
        main_align = "space_around",
        cross_align = "start",
        expanded = True,
    )

    return render.Root(
        child = render.Padding(child=output, pad=1),
    )

def offline():
    text = render.WrappedText("Offline")

    row = render.Row(
        children = [
            mini_gif(),
            render.Padding(child=text, pad=(1, 0, 1, 0)),
        ],
        main_align = "space_between",
        cross_align = "center",
        expanded = True,
    )

    return render.Root(
        child = render.Padding(child=row, pad=1),
    )

def idle():
    text = render.WrappedText("Idle")

    row = render.Row(
        children = [
            mini_gif(),
            render.Padding(child=text, pad=(1, 0, 1, 0)),
        ],
        main_align = "space_around",
        cross_align = "center",
        expanded = True,
    )

    return render.Root(
        child = render.Padding(child=row, pad=1),
    )

def center(child):
    return render.Row(
        children = [child],
        main_align = "space_around",
        cross_align = "center",
        expanded = True,
    )

def animate_progress_bar(progress, bar):
    scale = PROGRESS_BAR_WIDTH * progress
    return animation.Transformation(
        child = bar,
        duration = ANIMATION_DURATION,
        width = PROGRESS_BAR_WIDTH,
        origin = animation.Origin(0.0, 0.5),
        height = 10,
        keyframes = [
            animation.Keyframe(
                percentage = 0.0,
                transforms = [],
                curve = "ease_in_out",
            ),
            animation.Keyframe(
                percentage = 1.0,
                transforms = [animation.Scale(x=scale, y=1.0)],
            ),
        ]
    )

def animate_progress_cursor(progress, cursor):
    scale = PROGRESS_BAR_WIDTH * progress
    return animation.Transformation(
        child = cursor,
        duration = ANIMATION_DURATION,
        width = PROGRESS_BAR_WIDTH,
        origin = animation.Origin(0.0, 0.5),
        height = 8,
        keyframes = [
            animation.Keyframe(
                percentage = 0.0,
                transforms = [],
                curve = "ease_in_out",
            ),
            animation.Keyframe(
                percentage = 1.0,
                transforms = [animation.Translate(x=scale, y=0.0)],
            ),
        ]
    )

def up_and_out(text, start_delay=10):
    return animate_text_up(text, 0, -30, start_delay, 10)

def up_from_bottom(text, start_delay=10):
    return animate_text_up(text, 30, 0, start_delay, 10)

def animate_text_up(text, y_start, y_end, delay=0, duration=20):
    return animation.Transformation(
        child = text,
        duration = duration,
        delay = delay,
        height = 5,
        width = 62,
        keyframes = [
            animation.Keyframe(
                percentage = 0.0,
                transforms = [animation.Translate(x=0.0, y=y_start)],
                curve = "ease_in_out",
            ),
            animation.Keyframe(
                percentage = 1.0,
                transforms = [animation.Translate(x=0.0, y=y_end)],
            ),
        ]
    )

def mini_gif():
    src = base64.decode("R0lGODdhGwAYALMAAAAAACIgNEVJJN9xJmeW65utt8vb/P///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkUAAgALAAAAAAbABgAAAScEMlJKwIY2M1l1p1VjMH0hRVJeh+IFiWyIgYS3KhdUGt9x6HAjgfz4VBCUcEInAwGlGNlEKBKnQODFnDTUqzVq+RpOmq1v3BzDPWIEdYBd22Zb8gBTM67Ybo6ZBZME29sfTY4P4BtFX4dApBPkgOQApN5FpWVk0+bBARUf5qjpJafoBtpqqsDp4yEq7E3cqCvErKycgC2UbiKkxsRADs=")

    return render.Image(src)
