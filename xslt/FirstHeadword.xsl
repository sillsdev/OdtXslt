<?xml version="1.0" encoding="UTF-8"?>
<!-- #############################################################
    # Name:        FirstHeadword.xsl
    # Purpose:     Set headword to first one on the page
    #
    # Author:      Greg Trihus <greg_trihus@sil.org>
    #
    # Created:     2013/03/04
    # Copyright:   (c) 2013 SIL International
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
    
    <xsl:template match="office:text">
        <xsl:copy>
            <xsl:if test="count(@text:use-soft-page-breaks) = 0">
                <xsl:message terminate="yes">Soft page breaks are not marked in this document!</xsl:message>
            </xsl:if>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@text:name='Left_Guideword_L']">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:if test="local-name() != 'string-value'">
                    <xsl:copy/>
                </xsl:if>
            </xsl:for-each>
            <xsl:choose>
                <xsl:when test="count(preceding-sibling::text:span) = 0">
                    <xsl:choose>
                        <!-- start of document -->
                        <xsl:when test="local-name(parent::node()) = 'variable-decls' or local-name(parent::node()/parent::node()) = 'text'">
                            <xsl:attribute name="office:string-value">
                                <xsl:variable name="nextHeadword" select="parent::node()/following-sibling::text:section[2]/text:p[1]/text:span[1]"/>
                                <xsl:value-of select="normalize-space($nextHeadword)"/>
                            </xsl:attribute>
                        </xsl:when>
                        <!-- start of letter section -->
                        <xsl:when test="local-name(parent::node()/parent::node()) = 'section'">
                            <xsl:attribute name="office:string-value">
                                <xsl:variable name="nextHeadword" select="parent::node()/parent::node()/following-sibling::*[1]/text:p[1]/text:span[1]"/>
                                <xsl:value-of select="normalize-space($nextHeadword)"/>
                            </xsl:attribute>
                        </xsl:when>
                        <!-- end of letter section -->
                        <xsl:when test="count(parent::node()/parent::node()/following-sibling::*) = 0">
                            <xsl:attribute name="office:string-value">
                                <xsl:variable name="nextHeadword" select="ancestor::text:section/following-sibling::text:section[2]/text:p[1]/text:span[1]"/>
                                <xsl:value-of select="normalize-space($nextHeadword)"/>
                            </xsl:attribute>
                        </xsl:when>
                        <!-- page breaks at this entry -->
                        <xsl:when test="parent::node()/preceding-sibling::text:soft-page-break">
                            <xsl:attribute name="office:string-value">
                                <xsl:variable name="nextHeadword" select="parent::node()/preceding-sibling::text:span"/>
                                <xsl:value-of select="normalize-space($nextHeadword)"/>
                            </xsl:attribute>
                        </xsl:when>
                        <!-- normal entry -->
                        <xsl:otherwise>
                            <xsl:attribute name="office:string-value">
                                <xsl:variable name="nextHeadword" select="parent::node()/parent::node()/following-sibling::*[1]/text:span[1]"/>
                                <xsl:value-of select="normalize-space($nextHeadword)"/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="preceding-sibling::text:soft-page-break">
                            <xsl:attribute name="office:string-value">
                                <xsl:value-of select="preceding-sibling::text:span"/>                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="office:string-value">
                                <xsl:value-of select="parent::node()/following-sibling::node()[contains(@text:style-name,'entry')][1]/text:span"/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>