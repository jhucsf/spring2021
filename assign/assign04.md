---
layout: default
title: "Assignment 4: Image processing with plugins"
---

**Due**: Tuesday, April 4th by 11pm

**Assignment type**: Pair (you may work with one partner, or do the assignment individually)

# Image processing with plugins

In this assignment you will use *dynamic loading* to implement an image-processing application supporting *plugins* to allow the program to support arbitrary image transformation algorithms.

## Grading criteria

Your grade will be determined as follows:

* Driver program (`imgproc`): 40%
* `mirrorh` plugin: 10%
* `mirrorv` plugin: 10%
* `tile` plugin: 10%
* `expose` plugin: 10%
* Packaging: 10%
* Design and coding style: 10%

Make sure you follow the [style guidelines](style.html).

Your `imgproc` program and plugin shared libraries should execute without memory errors or memory leaks.  Memory errors such as invalid reads or write, or uses of uninitialized memory, will result in a deduction of up to 10 points.  Memory leaks will result in a deduction of up to 5 points.

## Programming Languages

You may use either C or C++ for this project.

# Tasks

This section describes how to get started and the tasks you will need to complete.

You can get started by downloading and unzipping the starter code: [csf\_assign04.zip](csf_assign04.zip)

A suggested approach is to start by implementing the [driver program](#driver-program) and using it to execute the provided `swapbg` plugin on the example image.  If it works correctly, you can move on to implementing the [image plugins](#image-plugins).

## Image data type and functions

The `image.h` and `image.c` files in the starter code define a datatype called `struct Image`, which represents a bitmapped true-color image.  The `struct Image` type is defined as follows:

```c
struct Image {
    unsigned width, height;
    uint32_t *data;
};
```

The `width` and `height` fields represent the width and height of the image.  The `data` array represents each pixel as a `uint32_t` element.  The pixel values are a packed representation, where bits 0-7 are the red component, bits 8-15 are the green component, bits 16-23 are the blue component, and bits 24-31 are the alpha component.  The alpha component determines the pixel's degree of transparency, where 0 means completely transparent and 255 means completely opaque.  For most images, the alpha values will be exclusively 255 (opaque.)

The following functions are defined for this datatype:

```c
struct Image *img_create(unsigned width, unsigned height);
struct Image *img_duplicate(struct Image *img);
void img_destroy(struct Image *img);
struct Image *img_read_png(const char *filename);
int img_write_png(struct Image *img, const char *filename);
void img_unpack_pixel(uint32_t pixel, uint8_t *r, uint8_t *g, uint8_t *b, uint8_t *a);
uint32_t img_pack_pixel(unsigned r, unsigned g, unsigned b, unsigned a);
```

Briefly:

* `img_create`, `img_duplicate`, and `img_destroy` are used for creating and destroying images
* `img_read_png` reads image data from a PNG file
* `img_write_png` writes image data to a PNG file
* `img_unpack_pixel` and `img_pack_pixel` are useful for splitting a pixel value into R/G/B/A values or packing R/G/B/A values into a pixel value

The header file `image.h` has detailed comments describing how each function works.

## Driver program

The *driver program* is responsible for loading the [image plugins](#image-plugins) and carrying out the command specified by the command-line parameters.

The exectable for the driver program should be called `imgproc`. If invoked without command line arguments, or with incorrect command line arguments, it should print a usage message.  Example:

```
$ ./imgproc
Usage: imgproc <command> [<command args...>]
Commands are:
  list
  exec <plugin> <input img> <output img> [<plugin args...>]
```

If `imgproc` is invoked with the `list` command, it should print the names and descriptions of each available plugin. Example:

```
$ ./imgproc list
Loaded 5 plugin(s)
 mirrorh: mirror image horizontally
 mirrorv: mirror image vertically
  swapbg: swap blue and green color component values
    tile: tile source image in an NxN arrangement
  expose: adjust the intensity of all pixels
```

The `list` command should produce one line of output per loaded plugin, as shown above.  You should use the exact description text shown above for your implementations of the `mirrorh`, `mirrorv`, `tile`, and `expose` plugins.  The ordering of the output lines is not important.

If `imgproc` is invoked with the `exec` command, it should use the named image plugin to transform a specified source image into a named destination image.  For example, here is a possible invocation to execute the `swapbg` plugin on `data/kitten.png` to produce the output file `kitten_swapbg.png`:

```
./imgproc exec swapbg data/kitten.png kitten_swapbg.png
```

The `tile` plugin requires a single command line argument (following the name of the output file), which is an integer specifying the tiling factor.  Example invocation:

```
./imgproc exec tile data/kitten.png kitten_tile_3.png 3
```

The `expose` plugin requires a single command line argument (following the name of the output file), which is a floating point value specifying the expose factor. Example invocation:

```
./imgproc exec expose data/kitten.png kitten_exp_0.5.png 0.5
```

### Hints and specifications for the driver program

**Very important**: Your driver program must *not* implement any of the image transformations. All of the image transformations must be implemented within the plugin shared libraries.

The main challenges for implementing the driver program are discovering which plugins are available, loading them, and getting pointers to the plugin API functions for each plugin.

To discover which plugins are available, the driver program should first determine which directory contains the plugin shared libraries.  If an environment variable called `PLUGIN_DIR` is set, the driver program should assume it contains the pathname of the plugin directory.  (Use the [getenv](https://linux.die.net/man/3/getenv) function to check whether this environment variable is set.)  Otherwise, it should assume that the plugin shared libraries are in the `./plugins` directory (i.e., the `plugins` subdirectory of the directory the driver program is running it.)

Once the driver program has determined the plugin directory, it should use the [opendir](https://linux.die.net/man/3/opendir), [readdir](https://linux.die.net/man/3/readdir), and [closedir](https://linux.die.net/man/3/closedir) functions to find all of the files in the plugin directory which end in the `.so` file extension.  Each such file should be assumed to be an image plugin shared library.

For each discovered plugin shared library, the driver program should dynamically load the shared library using [dlopen](https://linux.die.net/man/3/dlopen), and then use [dlsym](https://linux.die.net/man/3/dlsym) to find the addresses of the plugin's `get_plugin_name`, `get_plugin_desc`, `parse_arguments`, and `transform_image` functions.  You may find that it is useful to have a data structure which keeps track of the handle pointer and function pointer values for each loaded image plugin.  Here is a possible struct data type which could serve this purpose:

```c
struct Plugin {
    void *handle;
    const char *(*get_plugin_name)(void);
    const char *(*get_plugin_desc)(void);
    void *(*parse_arguments)(int num_args, char *args[]);
    struct Image *(*transform_image)(struct Image *source, void *arg_data);
};
```

Once the driver program has discovered and loaded the plugins, it should determine which command was specified, and carry out the command.

The `list` command should iterate through the plugins and use the `get_plugin_name` and `get_plugin_desc` commands to get the name and short description of each available plugin.

The `exec` command should find a plugin whose name matches the specified plugin name, load the specified input image (using `img_read_png`), pass any command line arguments (past the input and output filenames) to the plugin's `parse_arguments` function to produce an argument object, call the plugin's `transform_image` function to perform the image transformation (passing the argument object returned by `parse_arguments`), and then save the resulting image to the named output file (using `img_write_png`).  Note that it is the *plugin*'s responsibility to free the argument object.

**Important**: The driver program must contain the functions defined in `image.c` and `pnglite.c`.  Also:

* it must be linked against [zlib](https://www.zlib.net/) using the `-lz` linker option
* it must be linked against the dynamic loader library using the `-ldl` linker option
* it must be linked using the `-export-dynamic` option so that image plugins are able to call the functions in `image.c` (such as `img_create`)

If your Linux environment doesn't have the zlib development package installed, you will need to install it.  On Ubuntu-based systems, including the [CSF VM images](../resources.html#linux), use the command

```
sudo apt-get install zlib1g-dev
```

Here is an example of what the commands to compile and link the driver program might look like:

```
gcc -g -Wall -Wextra -pedantic -std=gnu99 -fPIC -c imgproc.c -o imgproc.o
gcc -g -Wall -Wextra -pedantic -std=gnu99 -fPIC -c image.c -o image.o
gcc -g -Wall -Wextra -pedantic -std=gnu99 -fPIC -c pnglite.c -o pnglite.o
gcc -export-dynamic -o imgproc imgproc.o image.o pnglite.o -lz -ldl
```

### Error handling

In any situation where the driver program cannot complete sucessfully, it should print an error message and exit with a non-zero exit code.  Examples of situations that are errors include:

* Missing or invalid command line arguments
* Unknown command name
* An image processing plugin can't be loaded
* A required API function can't be found within a loaded plugin
* A memory allocation error occurred

The error message printed if an error occurs should have the form

> <tt>Error: <i>text of error message</i></tt>

It is not important what text is printed for <tt><i>text of error mesage</i></tt>.  Error messages may be printed to either standard output or standard error.

As a special case, your driver program does *not* need to print an error message if the `imgproc` executable is invoked without any command line arguments. (It should just print the usage message in this case.)

## Image plugins

An *image plugin* is a Linux shared library defining four specific API functions.  You are responsible for implementing four image plugins:

* `mirrorh`
* `mirrorv`
* `tile`
* `expose`

The header file `image_plugin.h` defines the functions that each image plugin must implement:

```c
const char *get_plugin_name(void);
const char *get_plugin_desc(void);
void *parse_arguments(int num_args, char *args[]);
struct Image *transform_image(struct Image *source, void *arg_data);
```

There are detailed header comments in `image_plugin.h` explaining how these functions are intended to work.  In general:

* The `get_plugin_name` function returns the name of the plugin as a NUL-terminated character string
* The `get_plugin_desc` function returns a brief description of the plugin as a NUL-terminated character string
* The `parse_arguments` function requests that the plugin parse its portion of the command-line arguments; if the arguments are valid, it returns a pointer to an object containing the parsed argument data, otherwise it should return `NULL`
* The `transform_image` function returns a transformation of the specified source image, using the argument data object passed in as the `arg_data` parameter

The `swapbg.c` source file is an implementation of a complete image-processing plugin.  You can build it using the following commands:

```bash
gcc -g -Wall -Wextra -pedantic -std=gnu99 -fPIC -c swapbg.c -o swapbg.o
mkdir -p plugins
gcc -o plugins/swapbg.so -shared swapbg.o
```

The transformations performed by each plugin are described below.  Each transformation is applied to the following source image from [placekitten.com](http://placekitten.com/) (click for full size):

> <a href="img/kitten.png"><img alt="kitten" src="img/kitten.png" style="width:320px;"></a>

(Image by [latch.r](https://flickr.com/photos/lachlanrogers/), [some rights reserved](https://creativecommons.org/licenses/by-sa/2.0/))

### `swapbg` plugin

The `swapbg` plugin, which is provided in the starter code, performs a very simple transformation by swapping the blue and green color values of each pixel.  It does not take any command line parameters.  Example result (click for full-size):

> <a href="img/kitten_swapbg.png"><img alt="kitten b/g swap" src="img/kitten_swapbg.png" style="width:320px;"></a>

Note that as a result of the transformation, the kitten's brownish fur turned magenta.

### `mirrorh` plugin

The `mirrorh` plugin generates a mirror image of the input image, with all pixels being reflected horizontally.  It does not take any command line parameters.  Example result (click for full-size):

> <a href="img/kitten_mirrorh.png"><img alt="kitten mirrored horizontally" src="img/kitten_mirrorh.png" style="width:320px;"></a>

### `mirrorv` plugin

The `mirrorv` plugin generates a mirror image of the input image, with all pixels being reflected vertically. It does not take any command line parameters.  Example result (click for full-size):

> <a href="img/kitten_mirrorv.png"><img alt="kitten mirrored vertically" src="img/kitten_mirrorv.png" style="width:320px;"></a>

### `tile` plugin

The `tile` plugin generates an image containing an *N* x *N* arrangement of tiles, each tile being a smaller version of the original image, and the overall result image having the same dimensions as the original image.  It takes one command line parameter, an integer specifying the tiling factor *N*.

Example result images (click for full-size):

> *N* = 2 | *N* = 3
> ------- | -------
> <a href="img/kitten_tile_2.png"><img alt="kitten tiled 2x2" src="img/kitten_tile_2.png" style="width:320px;"></a> | <a href="img/kitten_tile_3.png"><img alt="kitten tiled 3x3" src="img/kitten_tile_3.png" style="width:320px;"></a>

Note that when the image's width or height isn't evenly divisible by *N*, the excess should be spread out, starting with the leftmost tiles (for excess width) and topmost tiles (for excess height).  For example, in the 3 x 3 case for an 800x600 source image, the tile widths should be 267, 267, and 266, and the tile heights should be 200, 200, and 200.

The tiles should sample every *N*th pixel from the source image horizontally and vertically.

## `expose` plugin

The `expose` plugin changes all red/green/blue color component values by a specified factor. It takes a single command line argument, which is the floating point value to use as the factor.  The factor must not be negative.  Note that if the factor is greater than 1, multiplying the factor by a color component value in the original image could result in a value greater than 255.  The transformation should limit all effective color component values to 255: this will cause "over-exposed" pixels to saturate towards white.

Example result images (click for full-size):

> Factor = 0.5 | Factor = 2.0
> ------------ | ------------
> <a href="img/kitten_exp_0.5.png"><img alt="kitten exposed 0.5" src="img/kitten_exp_0.5.png" style="width:320px;"></a> | <a href="img/kitten_exp_2.0.png"><img alt="kitten exposed 2.0" src="img/kitten_exp_2.0.png" style="width:320px;"></a>

# Packaging and submitting

Your implementation must have a `Makefile` such that executing `make` (i.e., building the default target) builds all of the following artifacts:

* the `imgproc` executable
* the `mirrorh`, `mirrorv`, `tile`, and `expose` plugin shared libraries, in the "plugins" directory

The exact name of the plugin shared libraries isn't important, but it's not a bad idea to have the shared library names match the plugin names.  For example, your `tile` plugin could be build as a shared library called `plugins/tile.so`.

Your `Makefile`'s `clean` target should delete all executables and shared libraries.

Submit all of the source files and header files needed by your driver program and plugin implementations, along with your `Makefile`, in a single zipfile.  For example, your command to produce the zipfile might look like the following:

```
$ zip -9r solution.zip Makefile *.c *.h
  adding: Makefile (deflated 51%)
  adding: demo.c (deflated 47%)
  adding: expose.c (deflated 58%)
  adding: image.c (deflated 69%)
  adding: imgproc.c (deflated 69%)
  adding: mirrorh.c (deflated 53%)
  adding: mirrorv.c (deflated 55%)
  adding: pnglite.c (deflated 76%)
  adding: swapbg.c (deflated 51%)
  adding: tile.c (deflated 63%)
  adding: image.h (deflated 57%)
  adding: image_plugin.h (deflated 56%)
  adding: pnglite.h (deflated 63%)
```

A reference `Makefile` is provided: [Makefile](assign04/Makefile).  You may use or adapt this `Makefile` if you choose to.

A second reference makefile might be appropriate if your driver program and/or plugins are implemented in C++: [Makefile2](assign04/Makefile2) (note that you will need to rename this as `Makefile`)

Submit your zipfile to [Gradescope](https://www.gradescope.com/) as **Assignment 4**.

<!--
vim:wrap linebreak nolist:
-->
