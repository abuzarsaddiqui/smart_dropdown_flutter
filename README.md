# Smart Dropdown

Smart Dropdown is a package which shows a dropdown in an elegant way.

## Install
Add this line to your pubspec.yaml:

```bash
dependencies:
  smart_dropdown: ^1.0.0
```
Then run this command:
```bash
$ flutter packages get
```
Then add this import:
```bash
import 'package:smart_dropdown/smart_dropdown.dart';
```

## Basic Example
Basic example demonstrates the use of smart dropdown. It also has an option to select any item by default.
```bash
SmartDropDown(
            items: items,
            hintText: "Smart Dropdown Demo",
            borderRadius: 5,
            borderColor: Theme.of(context).primaryColor,
            expandedColor: Theme.of(context).primaryColor,
          )
```
## Sample Image

![Sample Image](example/sample_asset/demo.png?raw=true "Title")

## License
[BSD](https://github.com/abuzarsaddiqui/smart_dropdown_flutter/blob/master/LICENSE/)