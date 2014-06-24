<?xml version="1.0" encoding="UTF-8"?>
<!-- #############################################################
    # Name:        SpaceB4Homograph.xsl
    # Purpose:     Remove apparent space before homograph numbers
    #
    # Author:      Greg Trihus <greg_trihus@sil.org>
    #
    # Created:     2014/06/24
    # Copyright:   (c) 2014 SIL International
    # Licence:     <LPGL>
    ################################################################-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
    version="1.0">
    
    <!-- Recursive copy template -->   
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[starts-with(@text:style-name, 'xhomograph')]">
        <xsl:element name="text:span">
            <xsl:attribute name="text:style-name">
                <xsl:value-of select="preceding-sibling::*/@text:style-name"/>
            </xsl:attribute>
            <xsl:element name="text:span">
                <xsl:attribute name="text:style-name">ti1</xsl:attribute>
                <xsl:element name="text:variable-set">
                    <xsl:attribute name="text:name">Placeholder</xsl:attribute>
                    <xsl:attribute name="office:value-type">string</xsl:attribute>
                    <xsl:text>1</xsl:text>
                </xsl:element>
            </xsl:element>
        </xsl:element>
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text:variable-decls">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
            <xsl:element name="text:variable-decl">Placeholder</xsl:element>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="office:automatic-styles">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
            <xsl:element name="style:style">
                <xsl:attribute name="style:name">ti1</xsl:attribute>
                <xsl:attribute name="style:family">text</xsl:attribute>
                <xsl:element name="style:text-properties">
                    <xsl:attribute name="text:display">none</xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>