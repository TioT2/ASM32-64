/// Mandelbrot set render implementation file

#ifndef MND_H_
#define MND_H_

#include <stdint.h>
#include <stddef.h>

/// Complex number structure
typedef struct mnd_compl__ {
    float r;
    float i;
} mnd_compl;

/// Add complex numbers
inline mnd_compl mnd_compl_add( mnd_compl lhs, mnd_compl rhs ) {
    return (mnd_compl) {
        .r = lhs.r + rhs.r,
        .i = lhs.i + rhs.i,
    };
}

/// Substract complex numbers
inline mnd_compl mnd_compl_sub( mnd_compl lhs, mnd_compl rhs ) {
    return (mnd_compl) {
        .r = lhs.r - rhs.r,
        .i = lhs.i - rhs.i,
    };
}

/// Multiply complex number on itself.
inline mnd_compl mnd_compl_square( mnd_compl c ) {
    return (mnd_compl) {
        .r = c.r * c.r - c.i * c.i,
        .i = 2.0 * c.r * c.i,
    };
}

/// Calculate square of complex number modulo.
inline float mnd_compl_mod2( mnd_compl c ) {
    return c.r * c.r + c.i * c.i;
}

/// Frame structure
typedef struct mnd_frame__ {
    uint32_t *data;
    size_t width;
    size_t height;
    size_t stride;
} mnd_frame;

/// Construct
void mnd_frame_ctor( mnd_frame *frame );

/// Frame destructor
void mnd_frame_dtor( mnd_frame *self );

/// Resize frame
void mnd_frame_resize( mnd_frame *self, size_t width, size_t height );

/**
 * Different rendering functionb
 */

/// Common rendering function
void mnd_render_portable(
    mnd_frame *frame,
    mnd_compl begin,
    mnd_compl end
);

/// @brief SSE-based rendering function
void mnd_render_sse(
    mnd_frame *frame,
    mnd_compl begin,
    mnd_compl end
);

void mnd_render_avx(
    mnd_frame *frame,
    mnd_compl begin,
    mnd_compl end
);

#endif // !defined(MND_H_)
