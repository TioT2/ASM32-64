
#include "mnd.h"

#include <stdio.h>
#include <xmmintrin.h>
#include <immintrin.h>

void mnd_render_avx(
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

    // 'r' initial value
    __m256 c_start_r = _mm256_add_ps(
        _mm256_set1_ps(begin.r),
        _mm256_mul_ps(
            _mm256_set1_ps(c_delta.r),
            _mm256_set_ps(7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0, 0.0)
        )
    );

    c_delta.r *= 8.0;

    __m256 c_i = _mm256_set1_ps(begin.i);

    // Render, actually
    for (size_t y = 0; y < height; y++) {
        __m256 c_r = c_start_r;

        c_i = _mm256_add_ps(c_i, _mm256_set1_ps(c_delta.i));

        for (size_t x = 0; x < stride; x += 8) {
            c_r = _mm256_add_ps(c_r, _mm256_set1_ps(c_delta.r));

            __m256 z_r = c_r;
            __m256 z_i = c_i;

            __m256 z_r2 = _mm256_mul_ps(c_r, c_r);
            __m256 z_i2 = _mm256_mul_ps(c_i, c_i);

            // Multidimensional count
            __m256 md_count = _mm256_setzero_ps();

            uint32_t count;
            for (count = 0; count < 255; count++) {
                __m256 z_ri = _mm256_mul_ps(z_r, z_i);

                z_r = _mm256_sub_ps(z_r2, z_i2);
                z_i = _mm256_mul_ps(_mm256_set1_ps(2.0), z_ri);
                z_r = _mm256_add_ps(z_r, c_r);
                z_i = _mm256_add_ps(z_i, c_i);
                z_r2 = _mm256_mul_ps(z_r, z_r);
                z_i2 = _mm256_mul_ps(z_i, z_i);

                __m256 mod2 = _mm256_add_ps(z_i2, z_r2);

                // Comparison mask
                __m256 cmp = _mm256_cmp_ps(mod2, _mm256_set1_ps(4.0), _CMP_LT_OQ);

                // Calculate comparison mask
                if (_mm256_movemask_ps(cmp) == 0)
                    break;

                md_count = _mm256_add_epi32(
                    md_count,
                    _mm256_and_ps(cmp, _mm256_set1_epi32(0x1101))
                );
            }

            _mm256_store_ps((float *)pixel_ptr, md_count);
            pixel_ptr += 8;
        }
    }
} // mnd_render_avx
