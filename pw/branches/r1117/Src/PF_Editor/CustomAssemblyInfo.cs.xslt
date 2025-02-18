﻿<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:param name="build"/>
  <xsl:param name="revision"/>
  <xsl:param name="revision_patched"/>
  <xsl:param name="line"/>
	<xsl:output method="text"/>
	<xsl:template match="/">
	using System.Reflection;
	using PF_Editor;

	[assembly: AssemblyFileVersionCustom( "<xsl:value-of select="Product/Version/Major"/>.<xsl:value-of select="Product/Version/Minor"/>.<xsl:value-of select="Product/Version/Patch"/>.<xsl:value-of select="$revision"/>" )]
	</xsl:template>
</xsl:transform>
