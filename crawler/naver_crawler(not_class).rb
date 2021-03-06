
# -----------------------------------------

# THIS FILE IS ONLY FOR TEST. DO NOT USE AND EDIT IT.
# final_test로 메인 controller에서 사용하지 마시오. 
# 테스트용이므로 이 파일을 수정하지도 말기 

# -----------------------------------------

# -----------------------------------------
# daum form_name : daumSearch
	 # input : q
# name form_name : sfrom
	 # input : query 

# 1. input 에 따른 주소가져오기
# 2. input 결과 창에서 블로그 버튼 눌렀을때로 이동
# 3. 블로그 결과에서 title, 소제 가져오기
# 4. 다음 페이지로 넘어가기
# 5. 링크로 들어가서 큰 content
# 6. readability
# -----------------------------------------

# blog 본문에 들어가 tag를 가져오는 메소드 시작

def get_tag(blog_link_uri)
		agent = Mechanize.new

		agent.ignore_bad_chunking = true
		agent.follow_meta_refresh = true
		agent.user_agent_alias = 'Windows Chrome'

		@tags = []
		
		# 새로운 에러
		# blog.me가 agent를 통해서 들어가게 되면 blog.com으로 바뀌는 현상
		# agent를 if문 밖으로 빼서 blog_link_uri 를 갱신
		# html 변수는 if문에서 계속 사용해야하므로 밖에서 영향력 없이 사용가능하도록 세팅 

		html = agent.get(blog_link_uri)
		blog_link_uri = html.uri.to_s

		# 

		if blog_link_uri.include? "blog.me"
			second_uri = html.search('frame').attr('src')
			page = agent.get(second_uri)
			page = page.search('frame').attr('src')
			blog_link_uri = "http://m.blog.naver.com" + page
		else
			blog_link_uri = blog_link_uri.gsub("http://", "http://m.")
		end
	
		page  = agent.get(blog_link_uri)
		page.search('div.post_tag').each do |t|
	  		@tags= t.text.gsub('#', '')
	  		puts @tags
	  	end
	
	# 원래 페이지로 돌아가기
	return @tags
end

# blog 본문에 들어가 tag를 가져오는 메소드 끝
# -----------------------------------------

require 'rubygems'
require 'mechanize'
require 'rest-client'
require 'resolv-replace.rb' 

# main가져오기
agent = Mechanize.new

agent.ignore_bad_chunking = true
agent.follow_meta_refresh = true
agent.user_agent_alias = 'Windows Chrome'

page = agent.get "http://naver.com"
search_form = page.form_with :name => "sform"
search_form.field_with(:name=>"query").value = "유아 장난감"
search_results = agent.submit search_form
main_uri = search_results.uri
# puts main_uri

# 메인에서 블로그 이동
page = agent.page.link_with(:text => '블로그').click


# 페이지를 5번째 페이지까지
for i in 1..5

	html = agent.get(page.uri).body
	html_doc = Nokogiri::HTML(html)
	blog_section = html_doc.css('ul#elThumbnailResultArea.type01')
	blog_head = blog_section.css('dt').css('a')
	blog_mini_content = blog_section.css('dd.sh_blog_passage')
	blog_date = blog_section.css('dd.txt_inline')

	# title 10개를 차례대로 뽑기
	blog_head.each_with_index do |v, i|
		puts i
		puts v.attr('title')
	end

	# 블로그 본문으로 들어가기 
	page = agent.page.link_with(:text => '다음페이지').click
	
	puts page.uri
	# if page.uri.include? "blog"
		puts "큰 한바퀴 "
		puts i

	for j in 0..8
		blog_link_uri = blog_head[j].attr('href')
		puts "작은 한바퀴"
		puts j
		puts blog_link_uri

		ary = Array.new	
		# 주소가 blog와 관련된 것만 태그를 뽑아옴 
		if blog_link_uri.include? "blog.me"
			ary=get_tag(blog_link_uri)
		elsif blog_link_uri.include? "blog.naver.com"
			ary=get_tag(blog_link_uri)
		else
		end
	end
end
