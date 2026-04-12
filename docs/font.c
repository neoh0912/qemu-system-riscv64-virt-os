struct UTF8MAP {

    WORD utf8;
    HALFWORD glyph;

};

struct FONT {

    WORD w,h;
    WORD size,length;

    *BYTE[lenght*size] glyphs;

    WORD utf8_map_size;
    *UTF8MAP[utf8_map_size] utf8_map;

    HALFWORD space;

};

struct PSF_FONT_HEADER {

    WORD Magic_bytes;
    WORD version;
    WORD Header_Size;
    WORD Flags;
    WORD Lenght;
    WORD Glyph_size;
    WORD Height;
    WORD Width;

};

FONT,ERROR font_load(*void font_binary) {

    FONT font = (FONT)malloc(sizeof(FONT));
    memset(font,0x0,sizeof(font);

    WORD magic = (WORD)((HALFWORD)font_binary[0]);

    if (magic == PSF1_FONT_MAGIC) {
        font_load_psf1(font,font_binary);
    } else {

        magic = (WORD)font_binary[0];

        if (magic == PSF_FONT_MAGIC) {
            font_load_psf(font,font_binary);
        } else {
            return NUL,-1
        }

    }

    if (font->utf8_map != 0) {
        font_sort_utf8_table(font);
        font->space = font_get_glyph(font,' ');
    }

    return font,0

}

void font_load_psf(FONT font,*void font_binary) {

    PSF_FONT_HEADER header = (PSF_FONT_HEADER)font_binary;

    font->w,font->h = header->Width,header->Height;
    font->size,font->lenght = header->Glyph_size,header->Lenght;

    u_size glyph_size = font->size*font->lenght;

    font->glyphs = malloc(glyph_size);

    memcpy(font->glyphs,&font_binary[header->Header_Size],glyph_size)

    if (header->Flags | 1 == 1) {
        font_parse_psf_utf8_table(font,font_binary)
    }

}

void font_parse_psf_utf8_table(FONT font,void* font_binary, u_size glyph_size) {

    font->utf8_map = malloc(font->lenght*sizeof(UTF8MAP));
    font->utf8_map_size = sizeof(font->utf8_map);
    BYTE* table = (BYTE*)font_binary;
    table += font_binary->Header_Size+glyph_size

    HALFWORD i = 0;
    HALFWORD j = 0;

    WORD utf8_BYTE;

    while (j < font->lenght) {

        utf8_BYTE = lbu(table++);
        if (utf8_BYTE == 0xFF) {
           ++j;
           continue;
        }
        
        if (utf8_BYTE > 0x7F) {
            utf8_BYTE = (utf8_BYTE << 8) | lbu(table++);
            if (utf8_BYTE > 0xDFBF) {
                utf8_BYTE = (utf8_BYTE << 8) | lbu(table++);
                if (utf8_BYTE > 0xEFBFBF) {
                    utf8_BYTE = (utf8_BYTE << 8) | lbu(table++);
                }
            }
        }
        font->utf8_map[i]->utf8 = utf8_BYTE;
        font->utf8_map[i]->glyph = j;

        if (++i >= font->utf8_map_size) {
            u_size size = utf8_map_size*2;
            void* map = malloc(size*sizeof(UTF8MAP));
            memcpy(map,font->utf8_map,font->utf8_map_size*sizeof(UTF8MAP));
            font->utf8_map_size = size;
            free(font->utf8_map);
            font->utf8_map = (UTF8MAP)map;
        }

    }

    u_size size = i*sizeof(UTF8MAP)
    void* map = malloc(size);
    memcpy(map,font->utf8_map,size)
    font->utf8_map_size = i;
    free(font->utf8_map)
    font->utf8_map = (UTF8MAP)map;

}

void font_sort_utf8_map(FONT font) {

}


HALFWORD font_get_glyph(WORD utf8) {

}

struct ARGS {
    HALFWORD glyph;
    void* buffer;
    DWORD w,offset;
    WORD fg,bg
};

void font_write_glyph(FONT font,struct ARGS* args) {
    DWORD w = args->w;
    glyph = font->glyphs[font->size*args->glyph];
    offset = args->offset*sizeof(WORD);
    DWORD k=0;
    for (i=0; i<font->h; i++) {
        BYTE bits;
        pos = offset;
        for (j=0, j<font->w; j++) {
            if (j%8 = 0) bits = glyph[k++];
            bit = bits & 0b10000000;
            bits = bits << 0x1;
            if (bit != 0) {
                buffer[pos] = fg;
            } else {
                buffer[pos] = bg;
            }
            pos += sizeof(WORD)
        }
        offset += w
    }
}

