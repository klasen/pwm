<%@ page import="password.pwm.http.servlet.configguide.ConfigGuideForm" %>
<%@ page import="password.pwm.util.StringUtil" %>
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

<% JspUtility.setFlag(pageContext, PwmRequestFlag.HIDE_LOCALE); %>
<% JspUtility.setFlag(pageContext, PwmRequestFlag.INCLUDE_CONFIG_CSS); %>
<!DOCTYPE html>
<%@ page language="java" session="true" isThreadSafe="true" contentType="text/html" %>
<% ConfigGuideBean configGuideBean = JspUtility.getSessionBean(pageContext, ConfigGuideBean.class);%>
<%@ taglib uri="pwm" prefix="pwm" %>
<html lang="<pwm:value name="<%=PwmValue.localeCode%>"/>" dir="<pwm:value name="<%=PwmValue.localeDir%>"/>">
<%@ include file="fragment/header.jsp" %>
<body class="nihilo">
<div id="wrapper">
    <%@ include file="fragment/configguide-header.jsp"%>
    <div id="centerbody">
        <form id="configForm">
            <%@ include file="/WEB-INF/jsp/fragment/message.jsp" %>
            <br/>
            <div id="outline_ldap" class="setting_outline">
                <div class="setting_title">
                    LDAP Test User (Optional)
                </div>
                <div class="setting_body">
                    <pwm:display key="ldap_testuser_description" bundle="ConfigGuide"/>
                    <div class="setting_item">
                        <div id="titlePane_<%=ConfigGuideForm.FormParameter.PARAM_LDAP_TEST_USER%>" style="padding-left: 5px; padding-top: 5px">
                            Example: <code><%=PwmSetting.LDAP_TEST_USER_DN.getExample(ConfigGuideForm.generateStoredConfig(configGuideBean).getTemplateSet())%></code>
                            <br/><br/>
                            <b>LDAP Test User DN</b>
                            <br/>
                            <input style="width:400px" class="configStringInput" id="<%=ConfigGuideForm.FormParameter.PARAM_LDAP_TEST_USER%>" name="<%=ConfigGuideForm.FormParameter.PARAM_LDAP_TEST_USER%>" value="<%=StringUtil.escapeHtml(configGuideBean.getFormData().get(ConfigGuideForm.FormParameter.PARAM_LDAP_TEST_USER))%>" autofocus/>
                            <button type="button" class="btn" id="button-browse-testUser">
                                <span class="btn-icon pwm-icon pwm-icon-sitemap"></span>
                                <pwm:display key="Button_Browse"/>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </form>
        <br/>
        <div id="healthBody" style="border:0; margin:0; padding:0; cursor: pointer">
            <div style="text-align: center">
                <button class="menubutton" style="margin-left: auto; margin-right: auto">
                    <pwm:if test="<%=PwmIfTest.showIcons%>"><span class="btn-icon pwm-icon pwm-icon-check"></span></pwm:if>
                    <pwm:display key="Button_CheckSettings" bundle="Config"/>
                </button>
            </div>
        </div>
        <%@ include file="fragment/configguide-buttonbar.jsp" %>
    </div>
    <div class="push"></div>
</div>
<pwm:script>
<script type="text/javascript">
    function handleFormActivity() {
        PWM_GUIDE.updateForm();
        clearHealthDiv();
        checkIfNextEnabled();
    }

    function clearHealthDiv() {
        PWM_MAIN.getObject('healthBody').innerHTML = PWM_VAR['originalHealthBody'];
    }

    PWM_GLOBAL['startupFunctions'].push(function(){
        PWM_VAR['originalHealthBody'] = PWM_MAIN.getObject('healthBody').innerHTML;
        checkIfNextEnabled();

        PWM_MAIN.addEventHandler('button_next','click',function(){PWM_GUIDE.gotoStep('NEXT')});
        PWM_MAIN.addEventHandler('button_previous','click',function(){PWM_GUIDE.gotoStep('PREVIOUS')});

        PWM_MAIN.addEventHandler('configForm','input',function(){handleFormActivity()});
        PWM_MAIN.addEventHandler('healthBody','click',function(){loadHealth()});

        PWM_MAIN.addEventHandler('button-browse-testUser','click',function(){
            UILibrary.editLdapDN(function(value){
                PWM_MAIN.getObject('<%=ConfigGuideForm.FormParameter.PARAM_LDAP_TEST_USER%>').value = value;
                handleFormActivity();
            })
        });
    });

    function checkIfNextEnabled() {
        var fieldValue = PWM_MAIN.getObject('<%=ConfigGuideForm.FormParameter.PARAM_LDAP_TEST_USER%>').value;
        PWM_MAIN.getObject('button_next').disabled = false;
        if (fieldValue.length && fieldValue.length > 0) {
            if (PWM_GLOBAL['pwm-health'] !== 'GOOD' && PWM_GLOBAL['pwm-health'] !== 'CONFIG') {
                PWM_MAIN.getObject('button_next').disabled = true;
            }
        }
    }

    function loadHealth() {
        var options = {};
        options['sourceUrl'] = 'ConfigGuide?processAction=ldapHealth';
        options['showRefresh'] = false;
        options['refreshTime'] = -1;
        options['finishFunction'] = function(){
            PWM_MAIN.closeWaitDialog();
            checkIfNextEnabled();
        };
        PWM_MAIN.showWaitDialog({loadFunction:function(){
            PWM_ADMIN.showAppHealth('healthBody', options);
        }});
    }
</script>
</pwm:script>
<%@ include file="fragment/footer.jsp" %>
</body>
</html>
