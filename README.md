# Easy-stabdif

This is a small wrapper script to run stable_diffusion.openvino with appropriate virtualenvs, possibly including the installation of some dependencies.

## Usage

### Requirements

* Linux (Fully automated installation is currently only supported on Ubuntu Jammy, Ubuntu Focal and Debian Bullseye)
* At least 16 GB of RAM.
* A CPU supported by openvino

### Quick start

```shell
./install.sh
./diffuse.sh --prompt "A beautiful meadow with many flowers, highly detailed oil painting" --seed 3735928559 --output meadow.png
```

### Text to Image

The popular standard use case. You enter a description / prompt and you get an image back.

Use `./diffuse.sh`. Documentation is available via `./diffuse.sh --help`. Especially common parameters are:

* --prompt [string]  
  Required. Used to specify what image should be generated.
* --seed [integer]  
  Optional. Can be used to create reproducible output for the same prompt
* --num-inference-steps [positive integer]  
  Optional. Lower values are faster to calculate, but tend to create fewer details and generally rougher / worse images. Default is 32. Experiment with values between 16 and 250.

### Inpainting

Combines a (jpg) image and a (png) mask to modify parts of the original images while keeping other parts identical.

Use `./inpaint.sh image-basename unique-id prompt [additional diffuse.sh arguments]`.

```shell
./inpaint.sh connery my-first-inpainting "The most handsome man in the world: manly, beautiful, smart, well-dressed" --num-inference-steps 64 --strength 0.6 --seed 968734
```

This will:

* Take image and mask with the basename "connery" (input/connery.jpg and input/connery-mask.png)
* Combine them with the specified prompt
* write the result to the file "output/connery-my-first-inpainting-a.jpg"
* Perform a few additional inference steps _without_ the mask to clean up possible edges
* write the results of that operation to "output/connery-my-first-inpainting-b.jpg"

Especially common parameters are, in addition to those used in the Text to Image scenario:

* --strength [float]  
  Optional. Lower values give less freedom to the neural net and remain closer to the input image

### Image to Image

Takes a rough sketch and a prompt, and generates a new, detailed image from those.

TODO