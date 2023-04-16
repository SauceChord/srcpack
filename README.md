# srcpack

## Running tests with busted (on Windows)

Open terminal and run `busted`. 
If `busted` cannot be found you have to install it. 

As of current writing I have been unable to install busted without the use of [scoop.sh](https://scoop.sh/)

### Installing scoop.sh via Powershell

- Open Powershell
- Run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Choose yes `y`
- Run `irm get.scoop.sh | iex`

### Installing luarocks via scoop

- Run `scoop install luarocks`

### Installing busted via luarocks

- Run `x86_64-w64-mingw32-gcc --version`
  - If this fails, proceed with the steps in **Installing x86_64-w64-mingw32-gcc** before continuing. The next step requires mingw32.
- Run `luarocks install busted`

### Installing x86_64-w64-mingw32-gcc via Cygwin

  - Install [Cygwin](http://cygwin.com/install.html) with `mingw64-x86_64-gcc-core` package.
  - Add Cygwins `bin` folder to PATH (eg. `C:/cygwin64/bin`)
  - Restart Powershell
  - Run `x86_64-w64-mingw32-gcc --version` from `C:/`
    - If this fails, something went wrong during installation
    - Did you add the `mingw64-x86_64-gcc-core` package?
    - Did you add the bin folder to PATH system environment variable?
    - Did you restart Powershell?
