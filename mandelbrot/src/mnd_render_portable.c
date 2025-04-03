#include "mnd.h"

/// Portable render function
void mnd_render_portable(
    mnd_frame *frame,
    mnd_compl begin,
    mnd_compl end
) {
    // Destination pixel pointer
    uint32_t *pixel_ptr = frame->data;
    size_t width = frame->width;
    size_t height = frame->height;
    size_t stride = frame->stride;

    mnd_compl c_delta = (mnd_compl) {
        .r = (end.r - begin.r) / (float)width,
        .i = (end.i - begin.i) / (float)height,
    };

    mnd_compl c = begin;

    // Render, actually
    for (size_t y = 0; y < height; y++) {
        c.i += c_delta.i;
        c.r = begin.r;

        for (size_t x = 0; x < width; x++) {
            c.r += c_delta.r;

            mnd_compl z = c;
            uint32_t count;

            for (count = 0; count < 255 && mnd_compl_mod2(z) < 4.0; count++)
                z = mnd_compl_add(mnd_compl_square(z), c);

            *pixel_ptr++ = count << 8;
        }

        // Add rest bytes
        pixel_ptr += stride - width;
    }
}
