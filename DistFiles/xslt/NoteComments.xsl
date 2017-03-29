<?xml version="1.0" encoding="UTF-8"?>
<!-- #############################################################
    # Name:        NoteComments.xsl
    # Purpose:     The SFM was opened in Word and comments inserted
    #              The process is to open the .doc file in LibreOffice
    #			   save as .odt and process with this script to
    #			   extract notes with references
    #
    # Author:      Greg Trihus <greg_trihus@sil.org>
    #
    # Created:     2017/03/29
    # Copyright:   (c) 2017 SIL International
    # Licence:     <MIT>
    ################################################################-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
	xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
	version="1.0">

	<xsl:output method="text"/>

	<xsl:template match="node()|@*">
		<xsl:apply-templates select="node()|@*"/>
	</xsl:template>

	<xsl:template match="office:annotation">
		<xsl:text>\note </xsl:text>
		<xsl:call-template name="GetCV">
			<xsl:with-param name="marker">\c </xsl:with-param>
			<xsl:with-param name="node" select="preceding::*[local-name() = 'span' or local-name() = 'p'][1]"/>
		</xsl:call-template>
		<xsl:text>:</xsl:text>
		<xsl:call-template name="GetCV">
			<xsl:with-param name="marker">\v </xsl:with-param>
			<xsl:with-param name="node" select="preceding::*[local-name() = 'span' or local-name() = 'p'][1]"/>
		</xsl:call-template>
		<xsl:text> </xsl:text>
		<xsl:for-each select=".//text:span">
			<xsl:if test="position() != 1">
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:value-of select="normalize-space(.)"/>
		</xsl:for-each>
		<xsl:value-of select=".//text:span"/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>

	<xsl:template name="GetCV">
		<xsl:param name="marker"/>
		<xsl:param name="node"/>

		<xsl:choose>
			<xsl:when test="starts-with($node,$marker)">
				<xsl:variable name="tx" select="substring-after($node,$marker)"/>
				<xsl:choose>
					<xsl:when test="contains($tx,' ')">
						<xsl:value-of select="substring-before($tx,' ')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$tx"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="prevNode" select="$node/preceding::*[local-name() = 'span' or local-name() = 'p'][1]"/>
				<xsl:if test="count($prevNode) > 0">
					<xsl:call-template name="GetCV">
						<xsl:with-param name="marker" select="$marker"/>
						<xsl:with-param name="node" select="$prevNode"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>