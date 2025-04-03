#include "mnd.h"

#include <stdio.h>
#include <xmmintrin.h>

void mnd_render_sse(
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

    __m128 c_start_r = _mm_add_ps(
        _mm_set_ps1(begin.r),
        _mm_mul_ps(
            _mm_set1_ps(c_delta.r),
            _mm_set_ps(3.0, 2.0, 1.0, 0.0)
        )
    );

    __m128 c_r;
    __m128 c_i = _mm_set_ps1(begin.i);

    // Render, actually
    for (size_t y = 0; y < height; y++) {
        c_r = c_start_r;
        c_i = _mm_add_ps(c_i, _mm_set1_ps(c_delta.i));

        for (size_t x = 0; x < stride; x += 4) {
            c_r = _mm_add_ps(c_r, _mm_set1_ps(c_delta.r * 4.0));

            __m128 z_r = c_r;
            __m128 z_i = c_i;

            // Multidimensional count
            __m128 md_count = _mm_setzero_ps();

            uint32_t count;
            for (count = 0; count < 255; count++) {
                __m128 z1_r = _mm_sub_ps(
                    _mm_mul_ps(z_r, z_r),
                    _mm_mul_ps(z_i, z_i)
                );

                __m128 z1_i = _mm_mul_ps(
                    _mm_set1_ps(2.0),
                    _mm_mul_ps(z_r, z_i)
                );

                z_r = _mm_add_ps(z1_r, c_r);
                z_i = _mm_add_ps(z1_i, c_i);

                __m128 mod2 = _mm_add_ps(
                    _mm_mul_ps(z_r, z_r),
                    _mm_mul_ps(z_i, z_i)
                );

                // Comparison mask
                __m128 cmp = _mm_cmple_ps(mod2, _mm_set1_ps(4.0));

                if (_mm_movemask_ps(cmp) == 0)
                    break;

                md_count = _mm_add_epi32(
                    md_count,
                    _mm_and_ps(cmp, _mm_set1_epi32(0x1101))
                );
            }

            _mm_store_ps((float *)pixel_ptr, md_count);
            pixel_ptr += 4;
        }
    }
}