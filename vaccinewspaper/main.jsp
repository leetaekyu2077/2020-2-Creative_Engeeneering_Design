<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<% request.setCharacterEncoding("utf-8"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <title>정보 전염병 면역력을 키워주는 백신, 백신문</title>
        <link rel="stylesheet" type="text/css" href="vaccinewspaper.css">
        <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.3/jquery.min.js"></script>
    </head>
    <body>
    <%
    	String url, title, writer, content, e_mail, reliability;
   	 	Connection conn=null;
		Statement stmt=null;
		ResultSet rs=null;
		String sql_update="";
		int id = 0, id2;
		int feed_back;
		int order_type = 0;
		
		//다음버튼 클릭 시 보내신 요청인 id값을 받아, 이전 페이지에서 보여지지 못했던 기사부터 보여줌
		if(request.getParameter("id") != null )
			id = Integer.parseInt(request.getParameter("id"));
		id2 = id+10;	//기사는 한 페이지에 10개까지
		
		//신뢰도순인지 최신순인지 확인
		if(request.getParameter("order") != null )
			order_type = Integer.parseInt(request.getParameter("order"));
		
		//DB연결
		try {
	   		Class.forName("com.mysql.jdbc.Driver");
	   		String jdbcurl = "jdbc:mysql://localhost:3306/vaccinewspaper?serverTimezone=UTC";
	   		conn = DriverManager.getConnection(jdbcurl, "root", "0000");
	   		stmt = conn.createStatement();
	   		
	   		//정렬 방식에 따라 다른 쿼리문 실행
	   		if(order_type == 0)
	   		{
	   			//신뢰도 순 정렬
	   			//피드백이 3명 이상일 때만 신뢰도 내림차순으로 정렬, 그 중에서는 id 내림차순으로 정렬, 10개까지 (피드백 기준인원은 사용자 증가에 따라 변경함)
	   			sql_update = "select * from articles order by case when feed_back >= 3 then reliability end desc, id desc limit "+id+", "+id2;	   		
	   		}
	   		else if(order_type == 1)
	   		{
	   			//최신순 정렬
	   			//id내림차순으로 정렬, 10개까지
	   			sql_update = "select * from articles order by id desc limit "+id+", "+id2;
	   		}
	   		
	   		rs = stmt.executeQuery(sql_update);
		}
		catch(Exception e) {
	   		out.println("DB 연동 오류입니다.:"+e.getMessage());
		}	
    %>
    	<div id="wrapper" class="">
        	<div id="main" class="flex-container">
        		<img id="banner"src="img/백신문 배너.png" onclick="go_main()">
        		<div class="content" class="">
        		<div class="flex-container">
        			<div id="reliability" class="order" onclick="order(0)">
        				신뢰도순 보기
        			</div>
        			<div id = "recent" class="order" onclick="order(1)">
        				최신순 보기
        			</div>
        		</div>
        		<% 
        			while(rs.next())
        			{
        				title = rs.getString("title");
        				url = rs.getString("url");
        				reliability = rs.getString("reliability");
        				feed_back = rs.getInt("feed_back");
        		%>
        		<!-- 메인페이지 기사 목록 -->
        		<div class="preview">
        			<div class="title"><a href = "article.jsp?id=<%=url%>"><%=title %></a></div>
            		<div class="reliability">
        			신뢰도 : <%           		
        				if(reliability == null || feed_back < 3)
        					out.print("평가 중...");
        				else
        				{
        					int value = Integer.parseInt(reliability);
        					
        					//각 기사들의 신뢰도 값에 따라 5가지 유형의 텍스트 출력
        					if(value > 80)
        						out.print("아주 좋음 :D");
        					else if(value > 50 && value <= 80)
        						out.print("좋음 :)");
        					else if(value > 30 && value <= 50)
        						out.print("보통 :|");
        					else if(value > 15 && value <= 30)
        						out.print("나쁨 :(");
        					else
        						out.print("아주 나쁨 :O");
        					%>
        			 <% } %>
        			</div> 
            	</div>          	
            	<%  } %>
            	<!-- 목록 하단 버튼 -->
            	<div class="bar flex-container">
            		<div id="update" class="bottom" onclick="update()">기사 새로고침</div>
           	    	<div id="next" class="bottom" onclick="go_next()">다음</div>
           		</div>
          </div> 
    	</div>
        <div id="footer">
            <div id="introduction">
                <h1>백신문 </h1>정보의 전염병을 치료하는 백신 (vaccinewspaper)
                <p>Developers &nbsp; :&nbsp; 저희믿조 - 김가은 장지원 류성호 김성현 이태규</p> 
            </div>       
        </div> 
    </div>  
    </body>
    <script type="text/javascript">
    	//플로팅 배너 클릭 시
        function go_main() {
            location.href = "main.jsp";
        }
		//다음버튼 클릭 시
        function go_next() {
            location.href = "main.jsp?id=<%=id2%>&order=<%=order_type%>";
		}
        //기사 새로고침 클릭 시
        function update() {
        	location.href = "crawling.jsp";
        }
		//신뢰도 순 or 최신순 버튼 클릭 시
        function order(value) {
        	location.href = "main.jsp?id=0&order="+value;
        }

        //왼쪽에 따라다니는 플로팅 배너를 위한 함수
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

    </script>
</html>