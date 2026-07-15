/*
 * Krema Dive — minimize/unminimize animation targeting the krema dock.
 *
 * The stock squash/magiclamp effects abort when a window has no taskbar
 * icon geometry, and krema does not publish one, so minimizing looked like
 * an instant disappear. This effect animates scale+fade+position toward
 * the bottom-center of the screen (the dock / dragon peek button) instead.
 */
"use strict";

const DURATION = 250;

function dockPoint(window) {
    const area = effects.clientArea(KWin.ScreenArea, window);
    return {
        x: area.x + area.width / 2,
        y: area.y + area.height - 10,
    };
}

function onMinimized(window) {
    if (effects.hasActiveFullScreenEffect) {
        return;
    }
    const p = dockPoint(window);
    if (window.kremaUnminimize) {
        cancel(window.kremaUnminimize);
        delete window.kremaUnminimize;
    }
    window.kremaMinimize = animate({
        window: window,
        duration: animationTime(DURATION),
        curve: QEasingCurve.InCubic,
        animations: [
            { type: Effect.Scale, to: 0.05 },
            { type: Effect.Opacity, to: 0.0 },
            { type: Effect.Position, to: { value1: p.x, value2: p.y } },
        ],
    });
}

function onUnminimized(window) {
    if (effects.hasActiveFullScreenEffect) {
        return;
    }
    const p = dockPoint(window);
    if (window.kremaMinimize) {
        cancel(window.kremaMinimize);
        delete window.kremaMinimize;
    }
    window.kremaUnminimize = animate({
        window: window,
        duration: animationTime(DURATION),
        curve: QEasingCurve.OutCubic,
        animations: [
            { type: Effect.Scale, from: 0.05 },
            { type: Effect.Opacity, from: 0.0 },
            { type: Effect.Position, from: { value1: p.x, value2: p.y } },
        ],
    });
}

function manage(window) {
    if (!window.normalWindow && !window.dialog) {
        return;
    }
    window.minimizedChanged.connect(() => {
        if (window.minimized) {
            onMinimized(window);
        } else {
            onUnminimized(window);
        }
    });
}

effects.windowAdded.connect(manage);
effects.stackingOrder.forEach(manage);
