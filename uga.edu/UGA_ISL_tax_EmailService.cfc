<!--- 
Custom email service from UGA's International Student Life Office.

This helps facilitate the tax preparation process.
--->

<cfcomponent extends="AbstractEmailService">
	
	<!--- Returns the name of the email service --->
	<cffunction name="getEmailServiceName" access="package" returntype="string">
		<cfreturn "EXAMPLE Email Service">
	</cffunction>
	
	<!--- Returns the description of the email service --->
	<cffunction name="getEmailServiceDescription" access="package" returntype="string">
		<cfreturn "EXAMPLE: Email students and scholars with the specified country of citizenship (required)" &
			        "along with an additional optional filter for visa status.">
	</cffunction>

	<!--- This method pulls the email addresses and returns them in a query.  Required filters are
		 taken into account, as well as any optional filters that were used. --->
	<cffunction name="getEmailQueryData" access="package" returntype="query">
		<cfargument name="emailRequestObject" type="EmailRequestObject" required="true">
		<cfargument name="useForReportFlag" type="boolean" required="true">
		<cfscript>
			var optionsArray = emailRequestObject.options;
		</cfscript>	
		
		<cfquery name="emailQuery">
			SELECT DISTINCT jbCommunication.idnumber, jbCommunication.universityEmail, jbCommunication.otherEmail, 
			jbInternational.firstname, jbInternational.lastname, jbInternational.midname, jbInternational.universityid
			FROM jbInternational 
			INNER JOIN jbCommunication ON jbInternational.idnumber = jbCommunication.idnumber
			
			WHERE jbCommunication.idnumber > 0
							
            AND ( jbInternational.citizenship = 'NULL' 
            <cfloop index="i" from="1" to="#ArrayLen(optionsArray)#">
                <cfif optionsArray[i].group eq "country">
                    OR jbInternational.citizenship = <cfqueryparam cfsqltype="cf_sql_varchar" value="#optionsArray[i].code#"> 
                </cfif>
            </cfloop> ) 
			
			<cfif containsGroup(emailRequestObject, "visa")>
				AND ( jbInternational.immigrationstatus = 'NULL' 
				<cfloop index="i" from="1" to="#ArrayLen(optionsArray)#">
					<cfif optionsArray[i].group eq "visa">
						OR jbInternational.immigrationstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#optionsArray[i].code#"> 
					</cfif>
				</cfloop> ) 
			</cfif>
			
			<cfif useForReportFlag>
			ORDER BY jbInternational.lastname, jbInternational.firstname, jbInternational.midname			
			FOR XML PATH
			</cfif>
			
		</cfquery>
		<cfreturn emailQuery>		
	</cffunction>
	
	<!--- this method builds and returns an array of the options to be displayed and 
		to filter on (if selected) for this email service --->
	<cffunction name="getOptions" access="private" returntype="array">
		<cfscript>
			var optionsArray = ArrayNew(1);
		</cfscript>

		<cfquery name="countriesQuery">
		SELECT code, description FROM codeCountry ORDER BY description
		</cfquery>
		<cfloop query="countriesQuery">
			<cfscript>
			countryOption = createObject("component", "Option");
			countryOption.code = countriesQuery.code;	
			countryOption.description = countriesQuery.description;
			countryOption.group = "country";
			countryOption.groupDesc = "Citizenship";
			ArrayAppend(optionsArray, countryOption);
			</cfscript>
		</cfloop>
		
		<cfquery name="visaQuery">
		SELECT code, description FROM codeVisa ORDER BY description
		</cfquery>
		<cfloop query="visaQuery">
			<cfscript>
			visaOption = createObject("component", "Option");
			visaOption.code = visaQuery.code;	
			visaOption.description = visaQuery.description;
			visaOption.group = "visa";
			visaOption.groupDesc = "Visa Status";
			ArrayAppend(optionsArray, visaOption);
			</cfscript>
		</cfloop>
				
		<cfreturn optionsArray>
	</cffunction>

</cfcomponent>
