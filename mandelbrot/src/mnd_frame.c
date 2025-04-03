#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "mnd.h"

#define FRAME_ALIGNMENT ((size_t)8)

static size_t align_up( size_t num, size_t align ) {
    return (num / align + (num % align != 0)) * align;
}

/// Construct
void mnd_frame_ctor( mnd_frame *frame ) {
    memset(frame, 0, sizeof(mnd_frame));
}

/// Frame destructor
void mnd_frame_dtor( mnd_frame *self ) {
    free(self->data);
    memset(self, 0, sizeof(mnd_frame));
}

/// Resize frame
void mnd_frame_resize( mnd_frame *self, size_t width, size_t height ) {
    free(self->data);

    self->width = width;
    self->height = height;
    self->stride = align_up(width, FRAME_ALIGNMENT);

    self->data = (uint32_t *)aligned_alloc(
        FRAME_ALIGNMENT * sizeof(uint32_t),
        self->height * self->stride * sizeof(uint32_t)
    );
    assert(self->data != NULL && "Frame reallocation failed!");
}