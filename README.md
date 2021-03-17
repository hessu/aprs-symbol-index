
APRS symbols index
=============================

This is the new master index of APRS symbol allocations and descriptions.

For easy manual editing in a text editor, the master file is in YAML format.

Converted versions in JSON and XML are provided in the generated/ directory. 
The YAML, JSON and XML documents can be embedded in APRS applications by
build systems and updated automatically.


Symbol identifiers
---------------------

APRS symbols are identified by two-character identifiers, such as '/>' or
'/A'.

The basic APRS symbol set is divided into two main tables (primary and
secondary). The primary table is identified by the first character of the
identifier being '/', and the secondary table is identified by the first
character being '\\'.

The symbols in the secondary table can additionally have an overlay
character - an upper-case letter or a number, which is drawn on top of the
symbol. In this case the first character of the symbol identifier, '\\' is
replaced by the overlay character. For example, 'A>' is the '\\A' symbol
with an A on top.

As a new development, the symbols with overlays have been allocated specific
meanings, creating an extended symbol set. Some clients are able to draw
specific graphics for these extended symbols.


Index structure
------------------

The index contains three lists:

- classes: A list of symbol classes, each defining a class identifier, a
  printable english shown name, and a description
- symbols: A list of symbols in the primary and secondary tables
- overlays: A list of symbols allocated in the extended symbols
  (secondary table with overlay characters)


Background information
-------------------------

Bob Bruninga has maintained an [APRS symbols index][symbolsx] on his web site. 
This was extended by the [symbol overlay extensions][symbolsnew].

This symbol allocation index intends to be compatible with those documents.

Symbol descriptions have been cleaned from additional text - only the symbol
itself is described.  Any additional metadata will be provided in separate
columns and structured fields instead of free-form text within the
descriptions, so that the files can be used within applications easily.


Licensing
------------

This list is maintained by Hessu, OH7LZB.  It is licensed under the
[CC BY-SA 4.0][ccbysa] license, so you're free to use it in any of your
applications.  For free.  Just mention the source somewhere in the small
print.


[symbolsx]: http://www.aprs.org/symbols/symbolsX.txt
[symbolsnew]: http://www.aprs.org/symbols/symbols-new.txt
[ccbysa]: http://creativecommons.org/licenses/by-sa/4.0/

