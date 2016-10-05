<?xml version="1.0" encoding="UTF-8"?>
<!-- #############################################################
    # Name:        Remove Cross Reference Callers.xsl
    # Purpose:     Modify Footnote callers
    #
    # Author:      Greg Trihus <greg_trihus@sil.org>
    #
    # Created:     2013/02/07
    # Copyright:   (c) 2013 SIL International
    # Licence:     <LPGL>
    ################################################################-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    version="1.0">

    <!-- Recursive copy template -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="text:note-citation">
        <xsl:copy>
            <xsl:attribute name="text:label">
                <xsl:choose>
                    <xsl:when test="normalize-space(text()) = '*'">
                        <xsl:text> </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>*</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="normalize-space(text()) = '*'">
                    <!-- thin space -->
                    <xsl:text disable-output-escaping="yes"><![CDATA[&#x2006;]]></xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>*</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="text:p[text:note]">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:copy/>
            </xsl:for-each>
            <xsl:for-each select="node()">
                <xsl:if test="local-name(.) = 'note' and substring-before(following-sibling::node()[2]/*/@*,'_') = 'VerseNumber'">
                    <xsl:apply-templates select="following-sibling::node()[2]"/>
                </xsl:if>
                <xsl:if test="not(local-name(.) = '' and local-name(following-sibling::node()[1]) = 'note')">
                    <xsl:if test="not(local-name(preceding-sibling::node()[2]) = 'note' and substring-before(*/@*,'_') = 'VerseNumber')">
                        <xsl:apply-templates select="."/>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="local-name(preceding-sibling::node()[1]) = 'note' and not(substring-before(following-sibling::node()[1]/*/@*,'_') = 'VerseNumber')">
                    <xsl:text xml:space="preserve"> </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>