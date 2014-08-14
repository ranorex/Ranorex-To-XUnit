<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes"/>
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
        <xsl:value-of select="//activity/@isotimestamp"/>
      </xsl:attribute>
      
      <xsl:attribute name="tests">
        <xsl:value-of select="count(//activity[(@testcasename and not(@iterationcount) and @result!='Ignored')])"/>
      </xsl:attribute>
     
      <xsl:attribute name="time">
        <xsl:value-of select="substring(//activity/activity/@duration, 1, string-length(//activity/activity/@duration)-1)"/> 
      </xsl:attribute>

      <xsl:for-each select="//activity[@testcasename and not(@iterationcount)]">
        <xsl:element name="testcase">
          <xsl:attribute name="classname">RanorexTestReport.<xsl:value-of select="@testcasename"/>
          </xsl:attribute>
          <xsl:attribute name="name">
            <xsl:choose>
              <xsl:when test="@iteration">
                  <xsl:value-of select="concat(@testcasename,'_Iteration: ',@iteration)"/>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:value-of select="@testcasename"/>
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

            <xsl:when test="@result='Failed'">
              <xsl:element name="failure">
                <!-- Provide ErrorMessage and Stacktrace in case of a Failure -->
                <xsl:attribute name="message">
                  <xsl:choose>
                  <xsl:when test="./activity[@result='Failed']/errmsg != ''">
                      <xsl:text>Module </xsl:text>
		      <xsl:value-of select="./activity[@modulename!='' and @result='Failed']/@modulename"></xsl:value-of> 
		      <xsl:text> reports --> </xsl:text>
                      <xsl:value-of select="normalize-space(./activity[@result='Failed']/errmsg)"></xsl:value-of>  
                  </xsl:when>
                    <xsl:otherwise >
                       <xsl:text>Container for loop</xsl:text>
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
