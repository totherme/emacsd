# Package-free emacs

What if you want to run emacs without any extra dependencies?

Here's one set of opinions.

```
mkdir -p ~/.emacs.d
touch ~/.emacs.d/custom.el
ln -s "$PWD/init.el" ~/.emacs.d/init.el
```
