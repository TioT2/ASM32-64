#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <linux/fb.h>
#include <stdint.h>

// Include
#include "mnd.h"

// Initialize render
int mnd_render_init_impl( struct mnd_render_context *context ) {
    // Open framebuffer
    int fb_file = open("/dev/fb0", O_RDWR);
    if (fb_file == -1) {
        mnd_print_fmt("Cannot open framebuffer\n");
        return 0;
    }
    mnd_print_fmt("FB File: 0x%x\n", fb_file);
    mnd_print_fmt("Framebuffer opened successfully\n");

    struct fb_var_screeninfo var_info;
    struct fb_fix_screeninfo fix_info;
    size_t fb_data_size = 0;
    size_t fb_data_offset = 0;
    size_t fb_data_stride = 0;

    // Actual fb data pointer, offset value used.
    uint8_t *fb_data = NULL;

    if (ioctl(fb_file, FBIOGET_VSCREENINFO, &var_info) == -1) {
        mnd_print_fmt("Error getting var_info\n");
        goto mnd_render_init__cleanup;
    }
    if (ioctl(fb_file, FBIOGET_FSCREENINFO, &fix_info) == -1) {
        mnd_print_fmt("Error getting fix_info\n");
        goto mnd_render_init__cleanup;
    }

    if (var_info.bits_per_pixel != 32) {
        mnd_print_fmt("32BPP expected.\n");
        goto mnd_render_init__cleanup;
    }

    fb_data_offset = var_info.xoffset * 4 + var_info.yoffset * fix_info.line_length;
    fb_data_size = var_info.xres * var_info.yres * 4;
    fb_data_stride = fix_info.line_length;

    fb_data = (uint8_t *)mmap(0, fb_data_size, PROT_READ | PROT_WRITE, MAP_SHARED, fb_file, 0);
    if ((size_t)fb_data == ~(size_t)0) {
        mnd_print_fmt("Cannot map framebuffer\n");
        goto mnd_render_init__cleanup;
    }

    *context = (struct mnd_render_context) {
        .fb_map_ptr = fb_data,
        .fb_file    = fb_file,
        .stride     = fix_info.line_length,
        .width      = var_info.xres,
        .height     = var_info.yres,
        .data       = fb_data + var_info.xoffset * 4 + var_info.yoffset * fix_info.line_length,
    };
    return 1;

mnd_render_init__cleanup:
    close(fb_file);
    return 0;
}
