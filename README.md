# Shares
File Provider app connecting the Files app to servers over various protocols. For iOS 11+.

# Protocols
Out of the box, Shares supports the following protocols:
* SFTP, using [SFTPKit](https://github.com/IMcD23/SFTPKit)

If you would like to see another protocol added to the app, file an issue, or feel free to contribute.

# Developing
Shares uses the [ibuild](https://github.com/IMcD23/ibuild) build system to manage dependencies. Install it using [homebrew](https://brew.sh):

`brew install IMcD23/brew/ibuild`

Dependencies are specified in [build.plist](build.plist).

There are a few submodules in the app as well, so run `git submodule update --init --recursive` before building the first time.

# Architecture
Shares acts as a bridge between the Files app on iOS and connections to various servers. These connections are written using the [ConnectionKit](https://github.com/IMcD23/ConnectionKit) framework.

Shares knows nothing about specific implementations of protocols. At runtime, Shares loads frameworks with a principal class that is written for ConnectionKit and presents them as available protocols to the user.

## Extensions
The Shares app merely exists for settings and account management. All other logic runs in the `File Provider` and `File Provider UI` extensions, which are presented in the Files app.

#### File Provider Extension
Provides data to the Files app, and is the process where all listing, uploading, and downloading of files occurs.

#### File Provider UI Extension
Displays UI inside the files app, when there are errors, actions need to be performed, or authentication needs to occur.

## Frameworks
Most core app logic is written in frameworks, and the app and extension targets contain only target-specific logic. There are two primary frameworks: SharesUI and SharesData.

#### SharesUI
User interface elements, used for authentication, settings, and more.

#### SharesData
Models, utilities, and more, which make the app work.

