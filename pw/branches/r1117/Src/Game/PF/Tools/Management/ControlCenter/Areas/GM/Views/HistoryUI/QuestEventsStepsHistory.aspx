﻿<%@ Page Title="GWEventsHistory" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="ViewPage<QuestEventsStepsModel>" %>

<asp:Content ID="cTitle" ContentPlaceHolderID="TitleContent" runat="server">
    QuestEventsStepsHistory
</asp:Content>

<asp:Content ID="cLinks" ContentPlaceHolderID="Links" runat="server">
  <link rel="stylesheet" href="/Content/pager.css" />
  <link href="../../../../Content/jquery-ui-1.8.17.custom.css" rel="stylesheet" type="text/css" />
  <style type="text/css">
    /* css for timepicker */
    .ui-timepicker-div .ui-widget-header { margin-bottom: 8px; }
    .ui-timepicker-div dl { text-align: left; }
    .ui-timepicker-div dl dt { height: 25px; margin-bottom: -25px; }
    .ui-timepicker-div dl dd { margin: 0 10px 10px 65px; }
    .ui-timepicker-div td { font-size: 90%; }
    .ui-tpicker-grid-label { background: none; border: none; margin: 0; padding: 0; }
  </style>
  
  <style type="text/css">
    .filter { border: 0; }
    .filter td { border: 0; }
    .saveButton { font-size: 150%; font-weight: bold; }
  </style>
  
  <script type="text/javascript" src="../../../../Scripts/jquery-ui-1.8.16.custom.min.js"></script>
  <script type="text/javascript" src="../../../../Scripts/jquery-ui-timepicker-addon.js"></script>
  <script type="text/javascript" src="../../../../Scripts/jquery-ui-sliderAccess.js"></script>
  <script type="text/javascript" src="../../../../Scripts/jquery.localizeDate.js"></script>

  <script type="text/javascript">
      $(document).ready(function () {
          localizeDate();
          $('#StartTime').datetimepicker({ dateFormat: 'dd.mm.yy', timeFormat: 'hh:mm:ss', showSecond: true });
          $('#EndTime').datetimepicker({ dateFormat: 'dd.mm.yy', timeFormat: 'hh:mm:ss', showSecond: true });
      });
  </script>
</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    
    <div id="pagemenu" style="width: 30%; float: right; margin-right: 0px">
      <%= Html.ActionLink("Back to account details", "Details", "Account", new { auid = Model.Auid }, new { })%>
    </div>
    
  
  <h3>Stages/Steps history (Quest Custom Event) for Auid: <%= Model.Auid %> </h3>
  <% using (Html.BeginForm()) { %>
  
    <%= Html.ValidationSummary(true) %>
    <div style="margin-top: 10px">
      <div >Start Time</div>
      <td><%= Html.TextBoxFor(m => m.StartTime, new Dictionary<string, object> { { "Value", Model.StartTime.ToString("dd.MM.yyyy HH:mm:ss") } })%></td>
      <%= Html.ValidationMessageFor(m => m.StartTime)%>
    </div>
    <div style="margin-top: 10px">
      <div >End time</div>
      <td><%= Html.TextBoxFor(m => m.EndTime, new Dictionary<string, object> { { "Value", Model.EndTime.ToString("dd.MM.yyyy HH:mm:ss") } })%></td>
      <%= Html.ValidationMessageFor(m => m.EndTime)%>
    </div>
    
    <br/>
    <input type="submit" value="Set time interval"/>

  <% } %>
  <br/>
  <br/>

    <%= Html.HiddenFor(m => m.Page) %>
    <%= Html.HiddenFor(m => m.TotalPages) %>

     <table>
        <tr>
            <% if (Model.Stage == -1){ %>
                <td></td>
                <td><b>Auid</b></td>
                <td><b>Stage Before</b></td>
                <td><b>Stage After</b></td>
                <td><b>TimeStamp</b></td>
                <td></td>
            <% } else {%>
                <td></td>
                <td><b>Auid</b></td>
                <td><b>Step Before</b></td>
                <td><b>Step After</b></td>
                <td><b>TimeStamp</b></td>
                <td><b>Stage</b></td>
            <% } %>
        </tr>
    <% for (int i = 0; i < Model.Events.Count; i++){ %>
        
        
         <tr>
           <td style="background-color: gold; color: black">
             <%= i + 1 %>
           </td>
           <td>
             <%= Model.Events[i].Auid%>
           </td>
             <td>
                 <%= Model.Events[i].ToStageStepChange - 1%>
             </td>
           <td>
             <%= Model.Events[i].ToStageStepChange%>
           </td>
            <td>
                <%= Model.Events[i].TimeStamp%>
            </td>
             <% if (Model.Events[i].Stage == -1){ %>
                 <td>
                     <%= Html.ActionLink("Show Steps", "QuestEventsStepsHistory", "HistoryUI", new { auid = Model.Auid, page = Model.Page, startTime = Model.StartTime, endTime = Model.EndTime, stage = Model.Events[i].ToStageStepChange }, null)%>
                 </td>
             <% } else {%>
                 <td>
                     <%= Model.Events[i].Stage%>
                 </td>
            <% } %>
         </tr>  
    
    <% } %>
    </table>
    
  
     <% if (Model.TotalPages == 0)
     {
       Model.TotalPages = 1;
       Model.Page = 1;
     } %>
    <br/>
    <br/>
    <div class="pager">
      Page :
      <% for (int i = 1; i <= Model.TotalPages; i++) { %>
        <%= Html.ActionLink(i.ToString(), "QuestEventsStepsHistory", "HistoryUI", new { auid = Model.Auid, page = i }, i == Model.Page ? new { @class = "selected" } : null)%>
      <% } %>
    </div>

</asp:Content>
