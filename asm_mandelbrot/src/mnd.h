#ifndef MND_RENDER_H_
#define MND_RENDER_H_

/// Mandelbrot rendering context
struct mnd_render_context {
    void * fb_map_ptr; ///< Framebuffer mapping pointer
    int    fb_file;    ///< Linux framebuffer file handle
    int    stride;     ///< Stride (bytes)
    int    width;      ///< Render width
    int    height;     ///< Render height
    void * data;       ///< Rendering destination
};

/// Initialize render
extern int mnd_render_init( struct mnd_render_context *context );

/// Terminate render
extern void mnd_render_term( struct mnd_render_context *context );

/// Display mandelbrot set, actually.
extern void mnd_render_draw( struct mnd_render_context *context );



/// Print formatted string
extern void mnd_print_fmt( const char *fstr, ... );

/// Flush input buffer
extern void mnd_flush( void );

/// Exit (terminate execution)
extern void mnd_exit( void );


#endif // !defined(MND_RENDER_H_)