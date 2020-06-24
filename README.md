> :warning: **DO NOT consider anything in this repo as stable, it's all WIP!**

# Foreword

![United States-International](.github/usintl-win.png)

Do you know the "United States-International" keyboard under Windows?
I think this layout is very practical for international users who need to write a lot of non-ASCII chars in different languages (German umlauts, anyone?) while still preserving a regular US-layout. 

...
Wait, why would I use a US-layout as a German Software Engineer? One simple reason: Efficiency! Many keys (think of `/` `~` etc.) are way more easily accessible. Additionally, some IDE keyboard layouts (for instance in JetBrains products) are also counting on easy access to these keys.

However, I also sometimes need to use umlauts (e.g. when writing with my colleagues). 
This is where the layout shines: It's still possible to "easily" type them while still profiting from a more efficient base layout.

For example: Whenever I want to type an - äähm - let's say `ä`, I have two choices:
- `<AltGr> + <q>` → Immediately produces `ä`
- `" + <a>` → After pressing `"`, the layout *awaits* another char (the `"` functioning as a lazy modifier) and is not immidiately printed. Finally, when pressing the `a`, the layout "knows" that you truly wanted an `a` with umlauts!

> Try it yourself! It's easier to get the point(s) then.

The first one is more difficult to remember, but the latter comes with a bigger downside: **DEAD KEYS! REST IN PEACE!**
Whenever you literally want to write a `"`, a space is needed. 
And oh no - there are even more of these modifying keys, e.g. ^ or `.
All these keys are dead! Let's resurrect them:

# Introducing winlayouts-‍🧟‍♂️

Under Linux, using undead keys is a trivial task because there is a special option (`nodeadkeys`) for the `altgr-intl` keyboard, for example using xorg `setxkbmap`: 

```setxkbmap -layout us -variant altgr-intl -option nodeadkeys```

Under Windows, there is no pre-defined magic layout for `nodeadkeys` and that is a huge pain.
Consequently, we have to build it manually. One upside is that Microsoft provides a free tool named "Keyboard Layout Creator" for this purpose.

I searched GitHub and hurray - luckily, user @umanovskis already created one and provides...
> [...] a layout that is like United States-International but removes the apostrophe ('), double quotes ("), circumflex (^), backtick (``) and tilde (~) as dead keys, while leaving the AltGr dead key combinations intact.
from [README](./layouts/us-intl-nodeadkeys/README.md)

That's exactly what we want! I forked the repo to achieve three additional goals:

1. Provide reproducable builds using a PowerShell script that can be easily understood
2. Use GitHub actions to compile it: 
    1. No need to download, install, execute the Microsoft tool just to compile your layout
    2. No need to trust a 3rd party to compile it without a possibly malicious intent 
3. Aggregate other useful, special or international keyboard layouts in the future

That's what this repository is all about.

## Available layouts

> :warning: Not stable yet

| Name                   | Country | Variant           | Description
| ---------------------- | ------- | ----------------- | -----------
| usintl-undead          | US      | AltGr-Intl        | Undead 
| usintl-undead-esc      | US      | AltGr-Intl        | Undead, Caps mapped to ESC for efficient vim usage using a hack mentioned [in the Colemak forum](https://forum.colemak.com/topic/870-hacked-msklc-to-enable-remapping-capslock/)


## Further information

To see a comparison between the original "United States-International" and the undead/nodeadkeys version, call `less -R layouts/usintl-undead/diff.txt`.