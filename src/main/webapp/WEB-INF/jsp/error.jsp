<%@ page import="password.pwm.error.ErrorInformation" %>
<%@ page import="password.pwm.http.JspUtility" %>
<%@ page import="password.pwm.http.servlet.PwmServletDefinition" %>
<%@ page import="password.pwm.http.tag.conditional.PwmIfTest" %>
<%--
  ~ Password Management Servlets (PWM)
  ~ http://www.pwm-project.org
  ~
  ~ Copyright (c) 2006-2009 Novell, Inc.
  ~ Copyright (c) 2009-2016 The PWM Project
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or
  ~ (at your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful,
  ~ but WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~ GNU General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  --%>

<!DOCTYPE html>
<%@ page language="java" session="true" isThreadSafe="true"
         contentType="text/html" %>
<%@ taglib uri="pwm" prefix="pwm" %>
<% final ErrorInformation errorInformation = (ErrorInformation)JspUtility.getAttribute(pageContext, PwmRequest.Attribute.PwmErrorInfo); %>
<html lang="<pwm:value name="<%=PwmValue.localeCode%>"/>" dir="<pwm:value name="<%=PwmValue.localeDir%>"/>">
<% JspUtility.setFlag(pageContext, PwmRequestFlag.HIDE_HEADER_BUTTONS); %>
<% JspUtility.setFlag(pageContext, PwmRequestFlag.HIDE_HEADER_WARNINGS); %>
<% JspUtility.setFlag(pageContext, PwmRequestFlag.NO_REQ_COUNTER); %>
<% JspUtility.setFlag(pageContext, PwmRequestFlag.HIDE_LOCALE); %>
<%@ include file="fragment/header.jsp" %>
<body class="nihilo" data-jsp-page="error.jsp">
<div id="wrapper">
    <jsp:include page="fragment/header-body.jsp">
        <jsp:param name="pwm.PageName" value="Title_Error"/>
    </jsp:include>
    <div id="centerbody">
        <div id="page-content-title"><pwm:display key="Title_Error" displayIfMissing="true"/></div>
        <br/>
        <h2><%=PwmConstants.PWM_APP_NAME%>&nbsp;<%=errorInformation == null ? "" : errorInformation.getError().getErrorCode()%></h2>
        <br/>
        <br/>
        <span id="message" class="message message-error"><pwm:ErrorMessage/></span>
        <br/>
        <br/>
        <pwm:if test="<%=PwmIfTest.showErrorDetail%>">
            <% if (errorInformation != null && !errorInformation.getError().isErrorIsPermanent()) { %>
            <div class="buttonbar">
                <form action="<pwm:url url='<%=PwmServletDefinition.Command.servletUrl()%>' addContext="true"/>" method="post" enctype="application/x-www-form-urlencoded">
                    <input type="hidden" name="processAction" value="continue"/>
                    <button type="submit" name="button" class="btn" id="button_continue" autofocus="autofocus">
                        <pwm:if test="<%=PwmIfTest.showIcons%>"><span class="btn-icon pwm-icon pwm-icon-forward"></span></pwm:if>
                        <pwm:display key="Button_Continue"/>
                    </button>
                    <input type="hidden" id="pwmFormID" name="pwmFormID" value="<pwm:FormID/>"/>
                </form>
            </div>
            <% } %>
        </pwm:if>
    </div>
    <div class="push"></div>
</div>
<%@ include file="fragment/footer.jsp" %>
</body>
</html>
