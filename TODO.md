# Streamer Mode TODO

## Regex
* [x] Make Matchadds Case Insensitive

* [x] Hide the contents of all SSH private keys (`id_rsa`, `id_ed25519`, `id_dsa`, etc.)  
  in any `.ssh` directory.  
    * [x] Add full-file conceals for `id_rsa`, `id_ed25519`, etc.
        * i.e., `*/.ssh/*[^\.pub]`
    * [x] Add support for private SSH keys with custom filenames.  

* [ ] Get this to work inside of Telescope pickers/previewers.


* [ ] Add option for user to add custom regex to act as keywords
    * Add `patterns` option to `setup()`
    * Then add those patterns to the `M.patterns`


* [x] Use `matchdelete()` on each match instead of `clearmatches()`
    * This should prevent any conflicts with other plugins/matches.


