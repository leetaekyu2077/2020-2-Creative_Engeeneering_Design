<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="org.jsoup.Jsoup" %>
<%@ page import="org.jsoup.nodes.Document" %>
<%@ page import="org.jsoup.nodes.Element" %>
<%@ page import="org.jsoup.select.Elements" %>
<% request.setCharacterEncoding("utf-8"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
    <%
    	//메인에서 보내진 클릭한 기사의 url값 받아서 저장
    	String url = request.getParameter("id");
    %>
        <title><%=url %></title>
        <link rel="stylesheet" type="text/css" href="vaccinewspaper.css">
        <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.3/jquery.min.js"></script>
    </head>
    <body>
    <%
    	int input=0, feed_back=0;
    	int reli = 0;
    	String title="", writer="", e_mail="",reliability="";
   	 	Connection conn=null;
		Statement stmt=null;
		ResultSet rs=null;
		String sql;
		
		//기사 url값으로 해당 웹페이지 불러오기
		Document doc = Jsoup.connect(url).post();
		
		//기사 본문 크롤링
		Elements element = doc.select("body > div.content > div > div.news-container > div.news-wrap > div.news-article > div.news-article-memo");
		String text = element.select("p").html();
		
		try {
	   		Class.forName("com.mysql.jdbc.Driver");
	   		String jdbcurl = "jdbc:mysql://localhost:3306/vaccinewspaper?serverTimezone=UTC";
	   		conn = DriverManager.getConnection(jdbcurl, "root", "0000");
	   		stmt = conn.createStatement();
	   		sql= "select * from articles where url= '"+url+"'";
	   		rs = stmt.executeQuery(sql);
		}
		catch(Exception e) {
	   		out.println("DB 연동 오류입니다.:"+e.getMessage());
		}		
		
    	if(rs.next())
    	{
    		//기사 데이터베이스에서 url로 찾은 기사의 정보를 저장
    		title = rs.getString("title");
    		writer = rs.getString("writer");
    		e_mail = rs.getString("e_mail");
    		reliability = rs.getString("reliability");
    		feed_back = rs.getInt("feed_back");
			
    	}
    %>
    <div id="wrapper">
    <!-- 기사 정보들 출력 -->
    	<div id="main" class="flex-container">
            <img id="banner"src="img/백신문 배너.png" onclick="go_main()">
        	<div class="content">
            <!--기사 사진 및 본문-->
            <div id="article">
                <div class="title">
                    <%=title %>
                </div>
                <div class="flex-container">
                	<div class="writer">
                		<%=writer + " " + e_mail%>
                	</div>
                	<progress id="bar" value="<%=reliability %>" min="0" max="100"></progress>
                </div>
                <div class="text">
                    <p> 
                    	<%=text %><br><br>
                    	원본 기사 링크 : <a href="<%=url %>"><%=url %></a>
                    </p>
                </div>
                <!-- 기사에 대한 피드백 기능 -->
                <div id="feedback">
                   	<h1>뉴스에 대한 피드백을 해주세요!</h1>
                   	<h2>위 기사를 읽고...</h2>
                   		                 	                	
                    <form class="flex-container" action="update.jsp" method="get">
                    	<div class="type"><h3>[긍정적]</h3></div>
                   		<div class="type"><h3>[부정적]</h3></div>  
                   		<!-- 긍정적 피드백은 value=1, 부정적 피드백은 value=0 -->
                   		<div class="input">
                   			<input type="checkbox" name="feedback" value="1"> 1. 기사를 읽고, 의구심이 들지 않고 믿을 만하다고 생각했다.
                   		</div>
                   		<div class="input">
                   			<input type="checkbox" name="feedback" value="0"> 1. 제목과 사진이 기사 내용과 상관없거나 과장되었다.
                   		</div>
                   		<div class="input">
                   			<input type="checkbox" name="feedback" value="1"> 2. 기사에 사용된 자료들의 출처가 분명하다.
                   		</div>
                   		<div class="input">
                   			<input type="checkbox" name="feedback" value="0"> 2. 기자의 주관적 의견이 반영되었다.
                   		</div>
                   		<div class="input">
                   			<input type="checkbox" name="feedback" value="1"> 3. 기사의 내용이 새로운 중요한 사실을 전달하고 있다.
                   		</div>
                   		<div class="input">
                   			<input type="checkbox" name="feedback" value="0"> 3. 기사가 부정적인 의도를 가지고 있다. (ex. 어그로, 타인 비판 등)
                   		</div>
                   		<div class="input">
                   			<input type="checkbox" name="feedback" value="1"> 4. 기사의 전개가 논리적이고 명확하다.
                   		</div>
                   		<div class="input">
                   			<input type="checkbox" name="feedback" value="0"> 4. 뉴스의 목적이 불분명하다.(ex. 의미없는 정보, 광고)
                   		</div>
                   		<div class="input">
                   			<input type="checkbox" name="feedback" value="1"> 5. 기사가 한쪽에 치우치지 않고 중립적이다.
                   		</div>
                   		<div class="input">
                   			<input type="checkbox" name="feedback" value="0"> 5. 뉴스의 내용이 사실과 다르다.
                   		</div>
                   		<div id="button" class="clearfix"> 
                   			<input class="button" type="submit" value="확인">
                   			<input class="button" type="reset" value="다시"> 
                   			<input type="hidden" name="id" value="<%=url%>">
                   		</div>            		
                   </form>
                   </div> 
                </div>
            </div>   
        </div>
      </div>
        <div id="footer">
            <div id="introduction">
                <h1>백신문 </h1>&nbsp;정보의 전염병을 치료하는 백신 (vaccinewspaper)
                <p>Developers &nbsp; :&nbsp; 저희믿조 - 김가은 장지원 류성호 김성현 이태규</p> 
            </div>       
        </div>
    </div> 
    </body>
    <script type="text/javascript">
    
        function go_main() {
            location.href = "main.jsp";
        }
        
        //왼쪽 백신문 플로팅 배너 함수
        $(document).ready(function() {

        // 기존 css에서 플로팅 배너 위치(top)값을 가져와 저장한다.
        var floatPosition = parseInt($("#banner").css('top'));
        // 250px 이런식으로 가져오므로 여기서 숫자만 가져온다. parseInt( 값 );

        $(window).scroll(function() {
        // 현재 스크롤 위치를 가져온다.
        var scrollTop = $(window).scrollTop();
        var newPosition = scrollTop + floatPosition + "px";
    
        $("#banner").stop().animate({"top" : newPosition}, 500);

        }).scroll();
    });
        var progress = document.getElementById("bar");
        var bar_value = progress.getAttribute("value");
        var value = parseInt(bar_value);
        var feed_back = "<%=feed_back%>"; 
        	
        //피드백이 없거나 기준인원을 넘지 못했을 경우 신뢰도 출력 보류
        if(bar_value == "null" || feed_back < 3)
        {
        	progress.style.setProperty("--b","#EAEAEA");
    		progress.style.setProperty("--c","#EAEAEA");
    		progress.style.setProperty("--d","'계산 중...'");
        }	
      //피드백이 기준인원이 넘었을 때만 기사 페이지에서 신뢰도를 출력
        else if(value > 80)
			progress.style.setProperty("--d","'아주 좋음 :D'");
		else if(value > 50 && value <= 80)
			progress.style.setProperty("--d","'좋음 :)'");
		else if(value > 30 && value <= 50)
			progress.style.setProperty("--d","'보통 :|'");
		else if(value > 15 && value <= 35)
			progress.style.setProperty("--d","'나쁨 :('");
		else
			progress.style.setProperty("--d","'아주 나쁨 :O'");

    </script>
</html>