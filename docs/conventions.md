# Conventions

This section explains several conventions used in this documentation.

## Symbols

This documentation use some symbols for illustration purposes. Before you read on, please make sure you've made yourself familiar with the following list of conventions:

### <!-- md:version --> – Version { data-toc-label="Version" }

The tag symbol in conjunction with a version number denotes when a specific feature or behavior was added. Make sure you're at least on this version if you want to use it.

### <!-- md:default --> – Default value { #default data-toc-label="Default value" }

Some properties in `.env` have default values for when the author does not explicitly define them. The default value of the property is always included.

#### <!-- md:default computed --> – Default value is computed { #default data-toc-label="is computed" }

Some default values are not set to static values but computed from other values, like the site language, repository provider, or other settings.

#### <!-- md:default none --> – Default value is empty { #default data-toc-label="is empty" }

Some properties do not contain default values. This means that the functionality that is associated with them is not available unless explicitly enabled.

### <!-- md:flag experimental --> – Experimental { data-toc-label="Experimental" }

Some newer features are still considered experimental, which means they might (although rarely) change at any time, including their complete removal (which hasn't happened yet).

### <!-- md:flag required --> – Required value { #required data-toc-label="Required value" }

Some (very few in fact) properties or settings are required, which means the authors must explicitly define them.

### <!-- md:flag customization --> – Customization { #customization data-toc-label="Customization" }

This symbol denotes that the thing described is a customization that must be added by the author.
