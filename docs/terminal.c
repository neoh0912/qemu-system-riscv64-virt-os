enum PARSER_STATE {
    ground,
    escape,
    escape_intermediate,
    csi_entry,
    csi_param,
    csi_intermediate,
    csi_ignore,
};

enum TRANSITION_ACTION {
    none,
    ignore,
    print,
    execute,
    clear,
    collect,
    param,
    esc_dispatch,
    csi_dispatch,
};

enum ACTION {
    none,
    print,
    execute,
    csi_dispatch,
    esc_dispatch,
}

struct PARSER {
    PARSER_STATE state;
    [MAX_INTERMEDIATE]BYTE intermediates;
    BYTE intermediates_idx;

    [MAX_PARAMS]HALFWORD params;
    [ceil(MAX_PARAMS/8)]BYTE params_sep;
    BYTE params_idx;
    HALFWORD param_acc;
    BYTE param_acc_idx;
};

table = struct {PARSER_STATE state, TRANSITION_ACTION transition}[][];

void char_display_write(CHAR_DISPLAY* char_display, BYTE* string, DWORD max_length) {

    DWORD i = 0;
    while ( i < max_length ) {

        BYTE byte = *string[i++];
        if (byte == 0) break;

        WORD utf8 = byte;
        WORD ch = byte;

        if (utf8 <= 0x7F)
            goto end;

        BYTE j = 1;

        if (utf8 >= 0xF0)
            ch ~&= 0xF0;
            j = 3;
            goto loop;
        if (utf8 >= 0xE0)
            ch ~&= 0xE0;
            j = 2;
            goto loop;
        ch ~&= 0xC0;
loop:
        while ( j > 0 ) {
            byte =  *string[i++];
            utf8 = (utf8 << 8) | byte;
            ch = ch<<6 | (byte & ~0x80);
            j--
        }

        if (ch > 0x9F) {
            char_display_write_utf8(self,utf8);
            continue;
        }
end:
        ACTION transition,entry = char_display_parser_next(self->parser,ch);
        char_display_handle_action(self,transition,utf8,ch);
        char_display_handle_action(self,entry,utf8,ch);

    }

}

void char_display_write_utf8(CHAR_DISPLAY self, WORD utf8) {
    WORD x,y = self->state->cursor->x,self->state->cursor->y;
    DWORD offset = y*self->w + x;

    WORD fg,bg = self->state->fg,self->state->bg;
    self->fg_buffer[offset] = fg;
    self->bg_buffer[offset] = bg;

    BYTE attribute = self->state->ansi->video;
    self->attribute_buffer[offset] = attribute;

    HALFWORD c = font_get_glyph(self->font,utf8);
    self->glyph_buffer[offset] = c;

    char_display_move_cursor(self,1,0);

}

void char_display_handle_action(CHAR_DISPLAY* self, ACTION action, WORD utf8, WORD ch) {
    if (action == .none) return;
    if (action == .print) return char_display_write_utf8(self,utf8);
    if (action == .execute) return char_display_execute(self,ch);
    if (action == .csi_dispatch) return char_display_csi_dispatch(self,ch,self->parser->intermediates,self->parser->params,self->parser->params_sep);
    if (action == .esc_dispatch) return char_display_esc_dispatch(self,ch,self->parser->intermediates);
}

void char_display_execute(CHAR_DISPLAY self,WORD ch) {
    if (ch > 0x7F) {
        char_display_esc_dispatch(self,ch - 0x40,NUL);
        return;
    }

    if (ch == "\b") char_display_move_cursor(self,-1,0);
    else if (ch == "\n") char_display_handle_newline(self);
    else if (ch == "\r") char_display_handle_carriage_return(self);
    else if (ch == "\t") char_display_handle_tab(self);
}

ACTION char_display_parser_next(PARSER* self, WORD ch) {
    PARSER_STATE state, TRANSITION_ACTION action = table[ch][self->state];

    ACTION transition = char_display_parser_do_action(self,action,ch);
    ACTION entry = .none;

    if (self->state != state) {
        if (state == .escape || state == .csi_entry) {
            char_display_parser_clear(self);
        }
    }

    self->state = state;
    return transition,entry;

}

ACTION char_display_parser_do_action(PARSER* self,TRANSITION_ACTION action, WORD ch) {
    if (action == .none || action == .ignore)
        return .none;
    if (action == .print)
        return .print;
    if (action == .execute)
        return .execute;
    if (action == .collect) {
        char_display_parser_collect(self,ch);
        return .none;
    }
    if (action == .param) {
        if (ch == ';' or ch == ':') {
            if (self->params_idx >= MAX_PARAMS)
                return .none;
            self->params[self->params_idx] = self->param_acc;
            if (ch == ':') self->params_sep.set(self->params_idx);
            self->params_idx += 1;

            self->param_acc = 0;
            self->param_acc_idx = 0;
            return .none;
        }

        self->param_acc *= 10;
        self->param_acc |= ch - '0';

        self->param_acc_idx++;
        return .none;
    }
    if (action == .csi_dispatch) {
        if (self->params->idx >= MAX_PARAMS) return .none;
        if (self->param_acc_idx > 0) {
            self->params[self->params_idx++] = self->param_acc;
        }
        if (c != 'm' && self->params_sep.count() > 0) return .none;
        return .csi_dispatch;
    }
    if (action == .esc_dispatch) return .esc_dispatch;
}

void char_display_parser_collect(PARSER* self,WORD ch) {
    if (self->intermediates_idx >= MAX_INTERMEDIATE) return;
    self->intermediates[self->intermediates_idx++] = ch;
}

void char_display_parser_clear(PARSER* self) {
    self->intermediates_idx = 0;
    self->params_idx = 0;
    self->params_sep = 0;
    self->param_acc = 0;
    self->param_acc_idx = 0;
}
