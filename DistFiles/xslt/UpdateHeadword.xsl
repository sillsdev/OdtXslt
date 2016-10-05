<?xml version="1.0" encoding="UTF-8"?>
<!-- #############################################################
    # Name:        UpdateHeadword.xsl
    # Purpose:     Set headword to first one on the page
    #
    # Author:      Greg Trihus <greg_trihus@sil.org>
    #
    # Created:     2016/10/04
    # Copyright:   (c) 2016 SIL International
    # Licence:     <MIT>
    ################################################################-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    version="1.0">

    <!-- Recursive copy template -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="office:text">
        <xsl:copy>
            <xsl:if test="count(@text:use-soft-page-breaks) = 0">
                <xsl:message terminate="yes">Soft page breaks are not marked in this document!</xsl:message>
            </xsl:if>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <!-- Remove current guidewords (if they exist) -->
    <xsl:template match="*[@text:name='Left_Guideword_L']"/>
    <xsl:template match="*[@text:name='RLeft_Guideword_L']"/>
    <xsl:template match="*[@text:name='Right_Guideword_R']"/>
    <xsl:template match="*[@text:name='RRight_Guideword_R']"/>
    <!-- Remove previous hidden style for variables -->
    <xsl:template match="office:automatic-styles/style:style[@style:name='THide']"/>

    <xsl:template match="office:automatic-styles">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
            <xsl:element name="style:style">
                <xsl:attribute name="style:name">THide</xsl:attribute>
                <xsl:attribute name="style:family">text</xsl:attribute>
                <xsl:element name="style:text-properties">
                    <xsl:attribute name="text:display">none</xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="text:p[starts-with(@text:style-name,'entry') or starts-with(@text:style-name,'minorentry') or starts-with(@text:style-name,'mainentry')]/*[1][local-name()='a']">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
        <xsl:element name="text:span">
            <xsl:attribute name="text:style-name">THide</xsl:attribute>
            <xsl:element name="text:variable-set">
                <xsl:attribute name="text:name">Left_Guideword_L</xsl:attribute>
                <xsl:attribute name="office:value-type">string</xsl:attribute>
                <xsl:value-of select="following::text:p[starts-with(@text:style-name,'entry') or starts-with(@text:style-name,'minorentry') or starts-with(@text:style-name,'mainentry')][1]/*[1]//text()" />
            </xsl:element>
        </xsl:element>
        <xsl:element name="text:span">
            <xsl:attribute name="text:style-name">THide</xsl:attribute>
            <xsl:element name="text:variable-set">
                <xsl:attribute name="text:name">RLeft_Guideword_L</xsl:attribute>
                <xsl:attribute name="office:value-type">string</xsl:attribute>
            </xsl:element>
        </xsl:element>
        <xsl:element name="text:span">
            <xsl:attribute name="text:style-name">THide</xsl:attribute>
            <xsl:element name="text:variable-set">
                <xsl:attribute name="text:name">Right_Guideword_R</xsl:attribute>
                <xsl:attribute name="office:value-type">string</xsl:attribute>
                <xsl:value-of select="ancestor::text:p[starts-with(@text:style-name,'entry') or starts-with(@text:style-name,'minorentry') or starts-with(@text:style-name,'mainentry')][1]/*[1]//text()" />
            </xsl:element>
        </xsl:element>
        <xsl:element name="text:span">
            <xsl:attribute name="text:style-name">THide</xsl:attribute>
            <xsl:element name="text:variable-set">
                <xsl:attribute name="text:name">RRight_Guideword_R</xsl:attribute>
                <xsl:attribute name="office:value-type">string</xsl:attribute>
            </xsl:element>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>