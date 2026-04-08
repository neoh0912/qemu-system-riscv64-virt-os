sizeof_CHAR_DISPLAY = 0x8+0x8+0x4+0x4 +0x8+0x8+0x8+0x8+0x4+0x4+0x4+0x4+0x1+0x2

CHAR_DISPLAY__device_handle = 0x0
CHAR_DISPLAY__font = 0x8
CHAR_DISPLAY__w = 0x10
CHAR_DISPLAY__h = 0x14

CHAR_DISPLAY__glyph_buffer = 0x18
CHAR_DISPLAY__fg_buffer = 0x20
CHAR_DISPLAY__bg_buffer = 0x28
CHAR_DISPLAY__attribute_buffer = 0x30

CHAR_DISPLAY__state = 0x38

CHAR_DISPLAY__state__cursor = 0x38

CHAR_DISPLAY__state__cursor__x = 0x38
CHAR_DISPLAY__state__cursor__y = 0x3C

CHAR_DISPLAY__state__fg = 0x40
CHAR_DISPLAY__state__bg = 0x44
CHAR_DISPLAY__state__tab_size = 0x48

CHAR_DISPLAY__state__ansi = 0x49

CHAR_DISPLAY__state__ansi__video = 0x49

CHAR_DISPLAY_DEFAULT_FG = 0xFFFFFFFF
CHAR_DISPLAY_DEFAULT_BG = 0x00000000

ANSI_INVERT = 0x1
