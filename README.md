
# Schema Documentation Generator Tool

This tool generates a schema reference guide (complete with navigable image maps) and optionally an integrated user guide (created from an XHTML skeleton file) from an XSD schema.
Prototyping has been performed to show that the tool can convert an RNG schema to XSD and maintain structured or XHTML documentation when converting to XSD prior to creating documentation from that XSD.

The documentation can be augmented by the inclusion (using a custom include approach) of XML samples (or subsets) and images and links added via a map file.
These contents can also be added to the user guide using the custom include markup and the user guide can also pull in auto generated content from the reference guide (such as navigable structure diagrams).

The assets (schema, images, sample XML and user guide XHTML skeleton) to be processed will be kept with each project.

The tool has been developed using XProc 1, XSLT3, RNG schema and XHTML.
The tool requires a recent versions of:

* Oxygen (to run manually or to generate the HTML and navigable images). Note if the script is to be run via a scheduled job  or automated process then a OXyegn Scripting Licence is also required.

* Calabash (to run the XProc)

* Saxon 9 HE/PE or Saxon 10

* Trang (to convert RNG schema in future)

RNG schemas are provided to allow authors to update the schema map file and user guide skeleton.

For further information see the top level Xproc file generateSchemaDoc.xpl

