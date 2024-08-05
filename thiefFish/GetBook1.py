# coding: utf-8
import requests
import os
from bs4 import BeautifulSoup
import time
from fake_useragent import UserAgent
import sys
import random
import json
import urllib.parse 

proxies = [{}]
#proxies = [{'http': 'http://59.55.161.88:3256', 'https': 'https://59.55.161.88:3256'},   {'http': 'http://103.37.141.69:80', 'https': 'https://103.37.141.69:80'},   {'http': 'http://124.205.153.36:80', 'https': 'https://124.205.153.36:80'},   {'http': 'http://60.191.11.241:3256', 'https': 'https://60.191.11.241:3256'},   {'http': 'http://175.7.199.229:6969', 'https': 'https://175.7.199.229:6969'},   {'http': 'http://27.191.60.36:8888', 'https': 'https://27.191.60.36:8888'},   {'http': 'http://121.4.36.93:8888', 'https': 'https://121.4.36.93:8888'}]
def href_Byname(book_name):
    '''
    通过传入的书号bookid，获取此书的所有章节目录
    :param book_id:
    :return: 章节目录及章节地址
    ''' 
    encoded_book_name = urllib.parse.quote(book_name[1].encode('gbk'))  
    url = 'https://www.biquge5.la/modules/article/search.php?searchkey={}&searchtype={}'.format(encoded_book_name,'articlename')
    headers = {
        'User-Agent':random_agent()}
        #'User-Agent': UserAgent().random}
        # 'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36'}
    response = requests.get(url, headers,proxies=random.choice(proxies))
    response.encoding = response.apparent_encoding
    response = BeautifulSoup(response.text, 'lxml')
    href = response.find('link').get('href')
    return href

def book_page_list(book_id):
    '''
    通过传入的书号bookid，获取此书的所有章节目录
    :param book_id:
    :return: 章节目录及章节地址
    '''
    url = 'https://www.biquge5.la/book/{}/'.format(book_id)
    headers = {
        'User-Agent':random_agent()}
        #'User-Agent': UserAgent().random}
        # 'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36'}
    response = requests.get(url, headers,proxies=random.choice(proxies))
    response.encoding = response.apparent_encoding
    response = BeautifulSoup(response.text, 'lxml')
    # 找到特定的 class  
    start_div = response.find(id='list').find(class_='clear')  

    # 在 start_div 下查找所有 <a> 标签  
    booklist = start_div.find_all_next('a') 
    return booklist


def book_page_text(bookid, booklist):
    '''
    通过书号、章节目录，抓取每一章的内容并存档
    :param bookid:str
    :param booklist:
    :return:None
    '''
    if os.path.exists('./txtPaths'):  
        os.remove('./txtPaths')
    try:
        for book_page in booklist:
            page_name = book_page.text.replace('*', '')
            page_id = book_page['href']
            url = 'https://www.biquge5.la/book/{}/{}'.format(bookid,page_id)
            headers = {
                'User-Agent':random_agent()}
                #'User-Agent': UserAgent().random}
                # 'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36'}
            response_book = requests.get(url, headers,proxies=random.choice(proxies))
            response_book.encoding = response_book.apparent_encoding
            response_book = BeautifulSoup(response_book.text, 'lxml')
            book_content = response_book.find('div', id="content")
            with open("./books/{}/{}.txt".format(bookid,page_name), 'a') as f:  
                book_content_wrap = wrap_string(book_content.text.replace('\xa0', '').replace('\ufffd', ''),58)
                f.write(book_content_wrap)
                print("当前下载章节：{}".format(page_name))
            with open("./txtPaths", 'a') as f:
                f.write("./books/{}/{}.txt".format(bookid,page_name)+"\n")
            time.sleep(2)
    except Exception as e:
        print(e)
        print("章节内容获取失败，请确保书号正确，及书本有正常内容。")

def random_agent():
    with open('./fake_agent/ua.json', 'r') as file:  
        data = json.load(file)  
        return random.choice(data) 

def wrap_string(string, line_length):  
    # 使用列表推导式和 join 方法  
    wrapped_lines = [string[i:i + line_length] for i in range(0, len(string), line_length)]  
    return '\n'.join(wrapped_lines)  

def getbook_main(bookname):
    href = href_Byname(bookname)
    time.sleep(1)
    bookid= href.split('/')[-2]
    
    # 如果书号对应的目录不存在，则新建目录，用于存放章节内容
    if not os.path.isdir('./books/{}'.format(bookid)):
        os.mkdir('./books/{}'.format(bookid))
    try:
        booklist = book_page_list(bookid)
        print("获取目录成功！")
        time.sleep(2)
        book_page_text(bookid, booklist)
    except Exception as e:
        print(e)
        print("获取目录失败，请确保书号输入正确！")

if __name__ == '__main__':
    #getbook_main('万古神帝')
    getbook_main(sys.argv)