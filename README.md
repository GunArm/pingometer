# pingometer
TL;DR: Tool for visualizing network reliability patterns using Powershell

Repeatedly pings a certain host (usually your default gateway which it finds automatically (but VPNs and multiple gateways can confuse this)) and prints a result character to the screen to indicate if the host was accessible.  The color-coded, single-character output allows a lot of data to be condensed on a screen at once into a map, which can be intuitively interpreted at a glance.

![This is not good](/../screenshots/screenshots/screen1.png?raw=true "This is not good")

The purpose is to help you easily analyze patterns of (un)reliability especially over wifi connections.  For example it's useful to know at the micro level how frequent outages are and how long they last.  What is the *shape* of the intermittent errors?  Seeing the difference between blips every few seconds vs every few minutes losing connectivity for a solid period of a few seconds could be telling.  I have even seen interference that seems very regular, by resizing the window (changing the wrapping length of the lines) I could line the blips up indicating constant interval of disturbance from some source.  It's pretty useful to see a picture like this of what is going on in order to direct your troubleshooting.

The ping timeout is very low to catch small blips and also to keep the graph moving at a near-constant rate.  Such low timeouts are impossible through the ping interface so they are performed directly through WMI calls that ping wraps anyway.

Aside from *success* and *timeout* there is a third result: an error in attempting to execute the ping, intermittent ones of these would likely indicate errors with your hardware or drivers.  Sometimes, however, I think WMI just gets overloaded (?) and it does this, so pingometer backs off it's test rate when it gets these, while printing multiple characters in order to try to keep the graph speed meaningful.

The script also, by default, grabs it's own window handle and sets it to always on top.  I like to let it do that, size the window narrowly (as seen below), and put it off to the side of my screen when I'm trying to keep an eye on it.  You can easily disable the always-on-top feature by commenting out the indicated line near the top of the script.

![Skinny mode, activate!](/../screenshots/screenshots/screen2.png?raw=true "Skinny mode, activate!")

PS: This thing is pretty spammy.  It's really intended to be used on your local default gateway in your network, though you can point it anywhere.  Be nice to people's servers...