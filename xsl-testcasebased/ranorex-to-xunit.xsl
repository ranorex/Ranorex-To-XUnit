<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes"/>

  <!-- template for transforming durations in miliseconds (ms) to duration in seconds -->  
  <xsl:template name="FormatDurationInMs">
    <xsl:param name="ValueInMs" />
    <xsl:choose>
      <xsl:when test="string-length($ValueInMs) &lt; 4" >
        <xsl:value-of select="substring($ValueInMs, 1,1)"></xsl:value-of>.<xsl:value-of select="substring($ValueInMs, 2,string-length($ValueInMs)-1)"></xsl:value-of>e-0<xsl:value-of select="4-string-length($ValueInMs)"></xsl:value-of>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="substring($ValueInMs, 1, string-length($ValueInMs)-3)"></xsl:value-of>.<xsl:value-of select="substring($ValueInMs, string-length($ValueInMs)-2,3)"></xsl:value-of>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="/">
    <xsl:element name="testsuite">
      
      <xsl:attribute name="name">
        <xsl:value-of select="//activity/@testsuitename"/>
      </xsl:attribute>
      
      <xsl:attribute name="errors">
       <xsl:value-of select="*/activity/@totalerrorcount"/>
      </xsl:attribute>
      
      <xsl:attribute name="failures">
        <xsl:value-of select="*/activity/@totalfailedcount"/>
      </xsl:attribute>
      
      <xsl:attribute name="skipped">
        <xsl:value-of select="*/activity/@totalblockedcount"/>
      </xsl:attribute>
      
      <xsl:attribute name="hostname">
        <xsl:value-of select="*/activity/@host"/>
      </xsl:attribute>
      
      <xsl:attribute name="timestamp">
        <!-- ISO8601_DATETIME_PATTERN -->
        <xsl:value-of select="//activity/@timestampiso"/>
      </xsl:attribute>
      
      <xsl:attribute name="tests">
     
        <xsl:value-of select="count(//activity[(@testcasename and @result!='Ignored' and not (parent::activity[@testcasename]))])"/>
        <!-- count test cases on outer level only / do not count setup, teardown, nested test cases or iterations  -->
      </xsl:attribute>
     
      <xsl:attribute name="time">
        <xsl:call-template name="FormatDurationInMs">
          <xsl:with-param name="ValueInMs" select="*/activity/activity/@durationms" />
        </xsl:call-template>
      </xsl:attribute>

      <xsl:for-each select="//activity[((@testcasename) or (@type='test case setup') or (@type='test case teardown')) and not (parent::activity[@testcasename])  ]">
        
        <!-- Iterate over all test cases on outer level only / do not report nested test cases or iterations-->

            <xsl:element name="testcase">
              <xsl:choose>
                <xsl:when test="@testcasename">
                  <xsl:attribute name="classname">
                    <xsl:text>RanorexTestReport.</xsl:text>
                    <xsl:value-of select="@testcasename"/>
                  </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="(@type='test case setup') or (@type='test case teardown')">
                      <xsl:attribute name="classname">
                        <xsl:text>RanorexTestReport.Setup/Teardown</xsl:text>
                      </xsl:attribute>
                    </xsl:when>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:attribute name="name">
                <xsl:choose>
                  <xsl:when test="@iteration">
                    <xsl:value-of select="concat(@testcasename,'_Iteration: ',@iteration)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:choose>
                      <xsl:when test="@testcasename">
                        <xsl:value-of select="@testcasename"/>
                      </xsl:when>

                      <xsl:otherwise>
                        <xsl:choose>
                          <xsl:when test="(@type='test case setup') or (@type='test case teardown')">
                            <xsl:text>Setup/Teardown</xsl:text>
                          </xsl:when>
                        </xsl:choose>
                      </xsl:otherwise>

                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>

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


              <xsl:choose>

                <xsl:when test="(@result='Failed')">
                  <xsl:element name="failure">
                    <!-- Provide ErrorMessage and Stacktrace in case of a Failure -->
                    <xsl:attribute name="message">

                      <xsl:choose>
                        <xsl:when test="./activity[@result='Failed']/errmsg != ''">
                          <!--Failure in Module -->
                          <xsl:text>Module </xsl:text>
                          <xsl:value-of select="./activity[(@modulename !='') and (@result='Failed')]/@modulename"></xsl:value-of>
                          <xsl:text> reports --> </xsl:text>
                          <xsl:value-of select="normalize-space(./activity[@result='Failed']/errmsg)"></xsl:value-of>

                        </xsl:when>
                        <xsl:otherwise >
                          <!--Failure in Module placed in nested Test Case-->
                          <xsl:text>Module </xsl:text>
                          <xsl:value-of select="descendant::activity[@result='Failed']/@modulename"></xsl:value-of>
                          <xsl:text> placed in Setup/Teardown reports --> </xsl:text>
                          <xsl:value-of select="normalize-space(.//item[@level='Error']/message)"></xsl:value-of>
                        </xsl:otherwise>
                      </xsl:choose>

                    </xsl:attribute>
                    <xsl:value-of select="normalize-space(.//item/metainfo/@stacktrace)"></xsl:value-of>
                  </xsl:element>
                </xsl:when>

                <xsl:otherwise>
                  <xsl:choose>

                    <xsl:when test="@result='Ignored'">
                      <xsl:element name="skipped">
                        <xsl:attribute name="message">
                          <xsl:text>Testcase skipped!</xsl:text>
                        </xsl:attribute>
                      </xsl:element>
                    </xsl:when>

                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>

            </xsl:element>

      </xsl:for-each>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
