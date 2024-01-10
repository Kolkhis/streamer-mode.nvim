# Streamer Mode TODO

## Regex
* [x] Make Matchadds Case Insensitive

* [x] Hide the contents of all SSH private keys (`id_rsa`, `id_ed25519`, `id_dsa`, etc.)  
  in any `.ssh` directory.  
    * [x] Add full-file conceals for `id_rsa`, `id_ed25519`, etc.
        * i.e., `*/.ssh/id_*[^\.pub] ]]`
    - Note that this is currently reliant on the filename starting with `id_`.  
    - Doesn't hide `----begin openssh private key----`
    - Does not (by design) hide public keys.


* [ ] Add option for user to add custom regex to act as keywords
    * This kind of already works...?

## Private Encryption Keys
* [ ] Add support for private GPG keys with custom filenames.
* [ ] Add support for private SSH keys with custom filenames.  

