<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<% request.setCharacterEncoding("utf-8"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
</head>
<body>
	<%
		int positive=0, negative=0, reliability=50, feed_back, result; 
		String url, temp="", temp2="";
   	 	Connection conn=null;
		Statement stmt=null;
		ResultSet rs=null;
		String sql;
		
		//피드백 확인버튼 클릭 시 전송되는 요청에서 정보 가져옴
		url = request.getParameter("id");
		String[] values = null;
				
		values = request.getParameterValues("feedback");
		
		if(values != null)
		{
			//피드백 항목에 따라 긍정적, 부정적 피드백 각각 갯수 세기
			for (String value : values)
			{
				if(value.equals("1"))
					positive++;
				else
					negative++;
			}
			
			try {
		  			Class.forName("com.mysql.jdbc.Driver");
		   			String jdbcurl = "jdbc:mysql://localhost:3306/vaccinewspaper?serverTimezone=UTC";
		   			conn = DriverManager.getConnection(jdbcurl, "root", "0000");
		   			stmt = conn.createStatement();
		   			sql= "select * from articles where url='"+url+"'";
		   			rs = stmt.executeQuery(sql);
				}
			catch(Exception e) {
		   			out.println("DB 연동 오류입니다.:"+e.getMessage());
				}		
				
			//데이터베이스에서 해당 기사의 피드백 받은 인원 수와 신뢰도 가져옴
			    if(rs.next())
				{
					temp = rs.getString("feed_back");
					temp2 = rs.getString("reliability");
				}	
				if(temp == null)
					feed_back = 0;
				else
					feed_back = Integer.parseInt(temp);
				
				if(temp2==null)
					reliability = 0;
				else
					reliability = Integer.parseInt(temp2);
				
				//신뢰도 계산
				result = 50+10*positive-10*negative;
				
				//위 결과를 추가하여 새로 평균을 계산
				reliability = (reliability*feed_back+result)/(++feed_back);
				
				//해당 기사의 피드백 인원과 신뢰도 업데이트
				sql = "update articles set feed_back='"+feed_back+"', reliability='"+reliability+"' where url='"+url+"'"; 
				stmt.executeUpdate(sql);
		}
		
		response.sendRedirect("article.jsp?id="+url);
	%>
</body>
</html>