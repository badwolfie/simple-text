#Simple Text (beta)
A very simple text and code editor written in Vala.

Compiling: make simple-text
Requires: vala, gtk+-3.0, gtksourceview-3.0

#### Currently working:
* Open files
* Save files
* Multiple tabs
* Toggle line numbers
* Regular text editor stuff

#### Not working:**
* Syntax highlighting
* Style schemes
* Text/Code completion
* Brace completion
* Re-open last tab
* To be defined...

#### Known bugs**
* The close button on tabs closes the current tab instead of the one it 
	  should
* Under yet unknown circumstances, it saves the buffer to a file called 
	  "Untitled" when its not supposed to