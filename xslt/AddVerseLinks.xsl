<?xml version="1.0" encoding="UTF-8"?>
<!-- #############################################################
    # Name:        AddVerseLinks.xsl
    # Purpose:     Add Verse Links
    #
    # Author:      Greg Trihus <greg_trihus@sil.org>
    #
    # Created:     2013/02/19
    # Copyright:   (c) 2013 SIL International
    # Licence:     <LPGL>
    ################################################################-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    version="1.0">
    
    <xsl:variable name="xhtml">http://www.w3.org/1999/xhtml</xsl:variable>
    
    <xsl:output  doctype-public="-//W3C//DTD XHTML 1.1//EN" 
        doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"/>
    
    <!-- Recursive copy template -->   
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[@class='Chapter_Number']">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
        <xsl:text> </xsl:text>
        <xsl:element name="a" namespace="{$xhtml}">
            <xsl:attribute name="href">
                <xsl:value-of select="substring-before(../xhtml:a[1]/@href,'#')"/>
            </xsl:attribute>
            <xsl:text>^</xsl:text>
        </xsl:element>
        <xsl:apply-templates select="(following::*[@class='Verse_Number' or @class='Chapter_Number'])[1]" mode="VerseLink"/>
    </xsl:template>
    
    <xsl:template match="*" mode="VerseLink">
        <xsl:if test="@class = 'Verse_Number'">
            <xsl:text> </xsl:text>
            <xsl:element name="a" namespace="{$xhtml}">
                <xsl:attribute name="href">
                    <xsl:text>#</xsl:text>
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
                <xsl:element name="span" namespace="{$xhtml}">
                    <xsl:attribute name="class">Verse_Link</xsl:attribute>
                    <xsl:value-of select="text()"/>
                </xsl:element>
            </xsl:element>
            <xsl:apply-templates select="(following::*[@class='Verse_Number' or @class='Chapter_Number'])[1]" mode="VerseLink"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*[@class='Verse_Number']">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
        <xsl:element name="a" namespace="{$xhtml}">
            <xsl:attribute name="href">
                <xsl:variable name="chapter" select="number(preceding::*[@class='Chapter_Number'][1]/text())"/>
                <xsl:value-of select="../../xhtml:a[$chapter]/@href"/>
            </xsl:attribute>
            <xsl:text>^</xsl:text>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>