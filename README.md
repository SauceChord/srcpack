# srcpack

## Running tests with [busted](https://lunarmodules.github.io/busted/) (on Windows)

- Open a Terminal
- Run `busted` 
- If `busted` cannot be found you have to install it (see below). 

As of current writing I have been unable to install busted without the use of [scoop.sh](https://scoop.sh/)

### 1. Installing scoop.sh via Powershell

- Open Powershell
- Run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Choose yes `y`
- Run `irm get.scoop.sh | iex`

### 2. Installing luarocks via scoop

- Run `scoop install luarocks`

### 3. Installing x86_64-w64-mingw32-gcc via Cygwin

- Run `x86_64-w64-mingw32-gcc --version`
- If this doesn't show version output, `x86_64-w64-mingw32-gcc` has to be installed.
  - Install [Cygwin](http://cygwin.com/install.html) with `mingw64-x86_64-gcc-core` package.
  - Add Cygwins bin folder to PATH (eg: `C:/cygwin64/bin`)
  - Restart Powershell
  - Run `x86_64-w64-mingw32-gcc --version` from `C:/` (or any other location than the bin folder)
    - If this fails, something went wrong during installation
    - Did you add the `mingw64-x86_64-gcc-core` package?
    - Did you add the bin folder to PATH system environment variable?
    - Did you restart Powershell?

### 4. Installing busted via luarocks

- Run `luarocks install busted`
- You should now be able to run the tests.
