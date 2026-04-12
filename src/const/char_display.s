MAX_INTERMEDIATE = 4
MAX_PARAMS = 24
sizeof_PARAM_SEP = MAX_PARAMS/8

sizeof_PARSER = 0x1+MAX_INTERMEDIATE+0x1+MAX_PARAMS*2+sizeof_PARAM_SEP+0x1+0x2+0x1

sizeof_STYLE = 0x8
sizeof_CURSOR = 0x4*2+sizeof_STYLE
sizeof_STATE = sizeof_CURSOR+0x4*2+0x1
sizeof_CHAR_DISPLAY = (0x8*2+0x4*2)+(0x8*4)+sizeof_STATE+sizeof_PARSER

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
CHAR_DISPLAY__state__cursor__style = 0x40

CHAR_DISPLAY__state__fg = 0x48
CHAR_DISPLAY__state__bg = 0x4C
CHAR_DISPLAY__state__tab_size = 0x50

CHAR_DISPLAY__parser = 0x51

PARSER__state = 0x0
PARSER__intermediates = 0x1
PARSER__intermediates_idx = (PARSER__intermediates + MAX_INTERMEDIATE)

PARSER__params = (PARSER__intermediates_idx + 0x1)
PARSER__params_sep = (PARSER__params + 2*MAX_PARAMS)
PARSER__params_idx = PARSER__params_sep + sizeof_PARAM_SEP
PARSER__param_acc = PARSER__params_idx + 0x1
PARSER__param_acc_idx = PARSER__param_acc + 0x2

sizeof_PARSER_STATE = 0x7

PARSER_STATE__ground = 0x0
PARSER_STATE__escape = 0x1
PARSER_STATE__escape_intermediate = 0x2
PARSER_STATE__csi_entry = 0x3
PARSER_STATE__csi_param = 0x4
PARSER_STATE__csi_intermediate = 0x5
PARSER_STATE__csi_ignore = 0x6

TRANSITION_ACTION__none = 0x0
TRANSITION_ACTION__ignore = 0x1
TRANSITION_ACTION__print = 0x2
TRANSITION_ACTION__execute = 0x4
TRANSITION_ACTION__clear = 0x5
TRANSITION_ACTION__collect = 0x6
TRANSITION_ACTION__param = 0x7
TRANSITION_ACTION__esc_dispatch = 0x8
TRANSITION_ACTION__csi_dispatch = 0x9

ACTION__none = 0x0
ACTION__print = 0x1
ACTION__execute = 0x2
ACTION__csi_dispatch = 0x3
ACTION__esc_dispatch = 0x4

CHAR_DISPLAY_DEFAULT_FG = 0xFFFFFFFF
CHAR_DISPLAY_DEFAULT_BG = 0x00000000

CURSOR_FLAG = 0x2

STYLE_inverse = 0x0
STYLE_invisible = 0x1
