# CMAKE
cmake_minimum_required(VERSION 3.14)


project(mandelbrot)
file(GLOB_RECURSE "source" CONFIGURE_DEPENDS
    src/*.c
)

add_executable(mandelbrot ${source})

# link dependencies
target_link_libraries(mandelbrot PRIVATE SDL3)
target_link_libraries(mandelbrot PRIVATE GL)

# Enable AVX and AVX2
target_compile_options(mandelbrot PRIVATE -mavx -mavx2)