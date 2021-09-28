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
    </head>
    <body>
    <%
    	int input=0, cnt=0, new_id=0;
    	int reli = 0;
    	String title="", writer="", e_mail="",reliability="", url="";
   	 	Connection conn=null;
		Statement stmt=null, stmt2=null;
		ResultSet rs=null, check=null;
		String sql;
		
		try {
	   		Class.forName("com.mysql.jdbc.Driver");
	   		String jdbcurl = "jdbc:mysql://localhost:3306/vaccinewspaper?serverTimezone=UTC";
	   		conn = DriverManager.getConnection(jdbcurl, "root", "0000");
	   		stmt = conn.createStatement();
	   		stmt2 = conn.createStatement();
	   		sql= "select max(id) as max_id, count(*) as cnt from articles";
	   		rs = stmt.executeQuery(sql);
		}
		catch(Exception e) {
	   		out.println("DB 연동 오류입니다.:"+e.getMessage());
		}	
		
		//현재 데이터베이스에서 가장 큰 id값 가져옴
		while(rs.next()) 
		{
			cnt = rs.getInt("cnt");
			
			if(cnt != 0)
				new_id = rs.getInt("max_id");
		}
		
		//웹 크롤링 부분
		//인사이트 홈페이지 열기
		Document doc = Jsoup.connect("https://www.insight.co.kr/").post();
		//메인 페이지의 기사 리스트 가져오기
		Elements list = doc.select("body > div.content > div > div > div.content-main > div.main-politics > div.main-politics-right > ul > li");
		
		//기사 리스트에서 각 리스트마다 정보 추출
		for (Element element : list)
		{
		    title = element.select("a").text().replaceAll("'", "''");	//제목
		    url = element.select("a").attr("abs:href");		//해당 기사를 눌렀을 때 이동하는 링크
		    //해당 기사 페이지 열기
		    doc = Jsoup.connect(url).post();
		    writer = doc.select("body > div.content > div > div.news-container > div.news-byline > span.news-byline-writer").text();	//기자 이름
		    e_mail = doc.select("body > div.content > div > div.news-container > div.news-byline > span.news-byline-mail").text();		//기자 이메일
			
		    //데이터 베이스에 해당 기사가 이미 있는지 확인
		    check = stmt2.executeQuery("select * from articles where url='"+url+"'");
		    
		    //없으면 해당 기사 정보를 데이터베이스에 추가
		    if(check.next()==false)
		    {
		    	new_id++;
		    	sql = "insert into articles values('"+url+"', '"+title+"', '"+writer+"', '"+e_mail+"', NULL, NULL, '"+new_id+"')";
		    	stmt.executeUpdate(sql);		    
		    }
		}
		
		response.sendRedirect("main.jsp");
			
	%>