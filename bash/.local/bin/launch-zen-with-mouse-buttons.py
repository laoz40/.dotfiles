#!/usr/bin/env python3
"""Open Zen Browser when left, right, and middle mouse buttons are held together."""

import subprocess
from select import select

from evdev import InputDevice, ecodes, list_devices

MOUSE_BUTTONS = {ecodes.BTN_LEFT, ecodes.BTN_RIGHT, ecodes.BTN_MIDDLE}
BUTTON_PRESSED = 1
BUTTON_RELEASED = 0


def supports_mouse_combo(device):
    keys = set(device.capabilities().get(ecodes.EV_KEY, []))
    return MOUSE_BUTTONS.issubset(keys)


def find_mouse_devices():
    devices = []

    for path in list_devices():
        try:
            device = InputDevice(path)
        except OSError:
            continue

        if supports_mouse_combo(device):
            devices.append(device)

    return devices


def is_mouse_combo_event(event):
    return event.type == ecodes.EV_KEY and event.code in MOUSE_BUTTONS


def update_pressed_buttons(event, pressed_buttons):
    if event.value == BUTTON_PRESSED:
        pressed_buttons.add(event.code)

    if event.value == BUTTON_RELEASED:
        pressed_buttons.discard(event.code)


def mouse_combo_is_held(pressed_buttons):
    return MOUSE_BUTTONS.issubset(pressed_buttons)


def open_zen_browser():
    subprocess.Popen(["zen-browser"])


def read_mouse_combo_events(devices):
    while True:
        readable_devices, _, _ = select(devices, [], [])

        for device in readable_devices:
            yield from filter(is_mouse_combo_event, device.read())


def should_launch_zen(pressed_buttons, already_triggered):
    return mouse_combo_is_held(pressed_buttons) and not already_triggered


def main():
    devices = find_mouse_devices()
    if not devices:
        raise SystemExit("No mouse devices with left/right/middle buttons found")

    pressed_buttons = set()
    already_triggered = False

    for event in read_mouse_combo_events(devices):
        update_pressed_buttons(event, pressed_buttons)

        if not mouse_combo_is_held(pressed_buttons):
            already_triggered = False
            continue

        if should_launch_zen(pressed_buttons, already_triggered):
            open_zen_browser()
            already_triggered = True


if __name__ == "__main__":
    main()
