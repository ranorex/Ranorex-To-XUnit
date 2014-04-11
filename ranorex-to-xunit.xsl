<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes"/>
  <xsl:template match="/">
    <xsl:element name="testsuite">
      
      <xsl:attribute name="name">
        <xsl:value-of select="//activity/@testsuitename"/>
      </xsl:attribute>
      
      <xsl:attribute name="errors">
        <xsl:value-of select="//activity/@totalerrorcount"/>
      </xsl:attribute>
      
      <xsl:attribute name="failures">
        <xsl:value-of select="//activity/@totalfailedcount"/>
      </xsl:attribute>
      
      <xsl:attribute name="skipped">
        <xsl:value-of select="//activity/@totalblockedcount"/>
      </xsl:attribute>
      
      <xsl:attribute name="hostname">
        <xsl:value-of select="//activity/@host"/>
      </xsl:attribute>
      
      <xsl:attribute name="timestamp">
        <!-- ISO8601_DATETIME_PATTERN -->
        <xsl:value-of select="//activity/@isotimestamp"/>
      </xsl:attribute>
      
      <xsl:attribute name="tests">
        <xsl:value-of select="count(//activity[(@testcasename and not(@iterationcount) and @result!='Ignored')])"/>
      </xsl:attribute>
     
      <xsl:attribute name="time">
        <xsl:value-of select="substring(//activity/activity/@duration, 1, string-length(//activity/activity/@duration)-1)"/> 
      </xsl:attribute>

      <xsl:for-each select="//activity[@modulename]">
        <xsl:element name="testcase">
          <xsl:attribute name="classname">RanorexTestReport.<xsl:value-of select="ancestor::activity[@testcasename]/@testcasename"/>
          </xsl:attribute>
          <xsl:attribute name="name">
            <xsl:value-of select="@modulename"/>
          </xsl:attribute>

          <xsl:attribute name="time">
            <xsl:choose>
              <xsl:when test="string-length(@durationms) &lt; 4" >
                <xsl:value-of select="substring(@durationms, 1,1)"></xsl:value-of>.<xsl:value-of select="substring(@durationms, 2,string-length(@durationms)-1)"></xsl:value-of>e-0<xsl:value-of select="4-string-length(@durationms)"></xsl:value-of>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="substring(@durationms, 1, string-length(@durationms)-3)"></xsl:value-of>.<xsl:value-of select="substring(@durationms, string-length(@durationms)-2,3)"></xsl:value-of>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>            

          <!-- Provide Details (Stacktrace) in case of a Failure -->
          <xsl:choose>
            <xsl:when test="@result='Failed'">
              <xsl:element name="failure">
                <xsl:attribute name="message">
                  <xsl:value-of select="normalize-space(errmsg)"></xsl:value-of>
                </xsl:attribute>
                  <xsl:value-of select="normalize-space(//item/metainfo/@stacktrace)"></xsl:value-of>
              </xsl:element>
            </xsl:when>
          </xsl:choose>

        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
