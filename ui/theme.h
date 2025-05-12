#ifndef MAINDO_THEME
#define MAINDO_THEME

#include "clay.h"

enum Theme {
  COLOR_TEXT_PRIMARY,
  COLOR_TEXT_SECONDARY,
  COLOR_PRIMARY,
  COLOR_SECONDARY,
  COLOR_BACKGROUND,
  COLOR_FOREGROUND,
  COLOR_SUCCESS,
  COLOR_WARNING,
  COLOR_ERROR,
  COLOR_MAX
};

enum ButtonVariant {
  BUTTON_FILLED,
  BUTTON_OUTLINED,
  BUTTON_DISABLED,
};

static const Clay_Color palette[COLOR_MAX] = {
    [COLOR_TEXT_PRIMARY] = (Clay_Color){210, 210, 210, 255},
    [COLOR_TEXT_SECONDARY] = (Clay_Color){100, 100, 100, 255},
    [COLOR_PRIMARY] = (Clay_Color){0, 100, 200, 255},
    [COLOR_SECONDARY] = (Clay_Color){0, 200, 100, 255},
    [COLOR_BACKGROUND] = (Clay_Color){10, 10, 10, 255},
    [COLOR_FOREGROUND] = (Clay_Color){240, 240, 240, 255},
    [COLOR_SUCCESS] = (Clay_Color){0, 200, 20, 255},
    [COLOR_WARNING] = (Clay_Color){130, 105, 4, 255},
    [COLOR_ERROR] = (Clay_Color){130, 50, 4, 255},
};

static Clay_Color mdo_theme_color(int theme) { return palette[theme]; }

#define BORDER_CONFIG                                                          \
  (Clay_BorderElementConfig) {                                                 \
    .width = {.left = 1.0, .right = 1.0, .bottom = 1.0, .top = 1.0},           \
    .color = mdo_theme_color(COLOR_FOREGROUND)                                 \
  }

#define CORNER_RADIUS                                                          \
  {.bottomLeft = 8.0, .bottomRight = 8.0, .topLeft = 8.0, .topRight = 8.0}

#endif // MAINDO_THEME
