#include <SDL3/SDL.h>
#include <GL/gl.h>

#include <assert.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <stdio.h>
#include <xmmintrin.h>

#include "mnd.h"

// TODO: Add movement?

// Caluclate average rendering time
double test_render(
    mnd_render_proc render_func,
    size_t frame_width,
    size_t frame_height,
    uint32_t repeat_count
) {
    clock();
}

int main( int argc, char **argv ) {
    SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS);

    SDL_Window *window = SDL_CreateWindow("MANDELBROT", 800, 600, SDL_WINDOW_OPENGL);
    SDL_GLContext window_gl_context = SDL_GL_CreateContext(window);
    SDL_GL_MakeCurrent(window, window_gl_context);

    // Initialize rendering destination
    mnd_frame frame = {0};
    mnd_frame_ctor(&frame);
    mnd_frame_resize(&frame, 800, 600);

    mnd_compl begin = { -2.5, -2.0 };
    mnd_compl end = { 1.5, 2.0 };

    bool do_render = true;

    const size_t update_frame_count = 32;
    size_t frame_count = 0;
    clock_t frame_time = 0;

    while (do_render) {

        // Handle SDL events
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
            case SDL_EVENT_QUIT: {
                do_render = false;
                break;
            }

            case SDL_EVENT_WINDOW_CLOSE_REQUESTED: {
                do_render = false;
                break;
            }

            // Resize
            case SDL_EVENT_WINDOW_RESIZED: {
                mnd_frame_resize(&frame, event.window.data1, event.window.data2);
                break;
            }
            }
        }

        // Render new frame
        clock_t start_time = clock();
        mnd_render_avx(
            &frame,
            begin,
            end
        );

        frame_time += clock() - start_time;
        frame_count++;

        if (frame_count >= update_frame_count) {
            double avg_frame_time = (double)frame_time / CLOCKS_PER_SEC * 1000.0 / update_frame_count;

            printf("FT: %lfms (%lf FPS)\n", avg_frame_time, 1000.0 / avg_frame_time);

            frame_count = 0;
            frame_time = 0;
        }

        glClear(GL_COLOR_BUFFER_BIT);
        glClearColor(0.30, 0.47, 0.80, 0.00);
        glDrawPixels(frame.stride, frame.height, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid *)frame.data);
        glFinish();

        SDL_GL_SwapWindow(window);
    }

    // Destroy frame
    mnd_frame_dtor(&frame);

    // Destroy OpenGL structures
    SDL_GL_MakeCurrent(window, NULL);
    SDL_GL_DestroyContext(window_gl_context);
    SDL_DestroyWindow(window);

    // Quit from SDL
    SDL_Quit();
}
