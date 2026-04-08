struct CHAR_DISPLAY {

    DEVICE* device_handle;
    FONT* font;
    WORD w,h;

    HALFWORD* glyph_buffer;
    WORD* fg_buffer;
    WORD* bg_buffer;
    BYTE* attribute_buffer;

    STATE state;

};

struct STATE {

    struct {
        WORD x,y;
    } cursor;

    WORD fg,bg;
    BYTE tab_size;

    struct {
        HALFWORD video;
    } ansi;

};

CHAR_DISPLAY char_display_create(DWORD device_id,FONT font,WORD w,h) {

    CHAR_DISPLAY char_display = (CHAR_DISPLAY)malloc(sizeof(CHAR_DISPLAY));
    char_display->device_handle = display_open(device_id);

    char_display->w = w;
    char_display->h = h;
    DWORD buffer_size = w*h;

    display_set_resolution(char_display->device_handle,w*font->w,h*font->h);

    char_display->font = font;

    char_display->state->cursor->x = 0;
    char_display->state->cursor->y = 0;

    char_display->state->fg = CHAR_DISPLAY_DEFAULT_FG;
    char_display->state->bg = CHAR_DISPLAY_DEFAULT_BG;

    char_display->state->tab_size = 4;

    char_display->state->ansi->video = 0;

    char_display->glyph_buffer = malloc(buffer_size*sizeof(HALFWORD));
    char_display->fg_buffer = malloc(buffer_size*sizeof(WORD));
    char_display->bg_buffer = malloc(buffer_size*sizeof(WORD));
    char_display->attribute_buffer = malloc(buffer_size*sizeof(BYTE));

    return char_display;

}

void char_display_flush(CHAR_DISPLAY char_display) {
    w,_ = display_get_resolution(char_display->device_handle);
    w *= sizeof(WORD);

    buffer = display_get_frame_buffer(char_display->device_handle);
    font = char_display->font

    for (y=0;y<char_display->h; y++) {
        for (x=0;x<char_display->w; x++) {
            
        }
    }



}
