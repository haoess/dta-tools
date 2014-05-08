This is a simple tool to create Markdown wiki pages from test files like the ones in _stylsheets/t_.

Format requirements for the test file: 
 - Every considered test has to start with "like".
 - Comments which start with "##" are copied.
 - A Comment which starts with "#--- " introduces a new file. The rest of the comment will be the file name. This kind of comment has to be read before any other writing action can be performed!
 - The "# " at the beginning of other Comments (which start with just a single "#") is omitted, the rest of the comment is copied.

Needed arguments:
1. Path to the test file
2. Path to the folder which contains _t/xml_
3. Output folder
