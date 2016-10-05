<?xml version="1.0" encoding="UTF-8"?>
<!-- #############################################################
    # Name:        MinorHeadword.xsl
    # Purpose:     Add headwords for minor entries
    #
    # Author:      Greg Trihus <greg_trihus@sil.org>
    #
    # Created:     2014/06/11
    # Copyright:   (c) 2014 SIL International
    # Licence:     <LPGL>
    ################################################################-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    version="1.0">

    <!-- Recursive copy template -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[starts-with(@text:style-name, 'headwordminor')]">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
        <xsl:element name="text:variable-set">
            <xsl:attribute name="text:name">Left_Guideword_L</xsl:attribute>
            <xsl:attribute name="text:display">none</xsl:attribute>
            <xsl:attribute name="text:formula">
                <xsl:text>ooow:</xsl:text>
                <xsl:value-of select="text()"/>
            </xsl:attribute>
            <xsl:attribute name="office:value-type">string</xsl:attribute>
            <xsl:attribute name="office:string-value">
                <xsl:value-of select="text()"/>
            </xsl:attribute>
        </xsl:element>
        <xsl:element name="text:variable-set">
            <xsl:attribute name="text:name">RLeft_Guideword_L</xsl:attribute>
            <xsl:attribute name="text:display">none</xsl:attribute>
            <xsl:attribute name="office:value-type">string</xsl:attribute>
        </xsl:element>
        <xsl:element name="text:variable-set">
            <xsl:attribute name="text:name">Right_Guideword_R</xsl:attribute>
            <xsl:attribute name="text:display">none</xsl:attribute>
            <xsl:attribute name="text:formula">
                <xsl:text>ooow:</xsl:text>
                <xsl:value-of select="text()"/>
            </xsl:attribute>
            <xsl:attribute name="office:value-type">string</xsl:attribute>
            <xsl:attribute name="office:string-value">
                <xsl:value-of select="text()"/>
            </xsl:attribute>
        </xsl:element>
        <xsl:element name="text:variable-set">
            <xsl:attribute name="text:name">RRight_Guideword_R</xsl:attribute>
            <xsl:attribute name="text:display">none</xsl:attribute>
            <xsl:attribute name="office:value-type">string</xsl:attribute>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>