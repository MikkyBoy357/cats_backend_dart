# cats_backend

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
[![Powered by Dart Frog](https://img.shields.io/endpoint?url=https://tinyurl.com/dartfrog-badge)](https://dartfrog.vgv.dev)

# Description
This is a simple REST backend.
Think of it as a template for building a REST backend in Dart.


## Features
##### ✅ Authentication (*Login, Register*)
##### ✅ User Profile (*Avatar, Bio*)
##### ✅ Profile (*Follow, Unfollow*)
##### 🚧 Posts (*Post, Like, Comment*)
##### ✅ Chat (*Send, Receive, Send Image*)
##### ✅ ChatMessage Read Receipt (*Delivered, Read*)

## How to run
1. Clone the repository `git clone https://github.com/MikkyBoy357/cats_backend_dart.git`
2. Change directory `cd cats_backend_dart`
3. Install dart_frog_cli globally `pub global activate dart_frog_cli`
4. Configure the credentials in `lib/config/congig.dart`
5. Add the `firebase_options.json` file in the root directory
6. Compile landing page dart2js `dart2js -o public/main.dart.js public/main.dart`
7. Run the server `dart_frog dev`

## Docs

- [Pull Request Template](/docs/pull_request_template.md)

# Author
- [St.](https://github.com/MikkyBoy357)

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis