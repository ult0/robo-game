# Godot Layer Name Enums

Automatically generate user friendly lookups of project layer names.

![useage](https://github.com/user-attachments/assets/482c9bc3-ae43-4132-b716-04e4a5caa298)


## Installation

Copy the `addons/layerNames` directory into your `res://addons/` directory, or install via the [Asset Library](https://godotengine.org/asset-library/asset/3372)

Go to `Project` -> `Project Settings` -> `Plugins` and enable `Layer Names`.

![install](https://github.com/user-attachments/assets/382c36c1-4bdc-4599-92ef-ef6246ab9c8b)


## License

Licensed under the [MIT license](LICENSE)

## Running Tests

This project uses the [GUT](https://github.com/bitwes/Gut) testing framework. To run the tests:

1. Install the GUT plugin by copying it into `res://addons/gut` and enable it in `Project Settings -> Plugins`.
2. Launch Godot and run the GUT test runner scene or execute it via command line:

```bash
# Example command line
godot --headless -s res://addons/gut/gut_cmdln.gd -d -gdir=res://tests
```

The tests in `tests/` will verify core utilities such as the `PriorityQueue`.
