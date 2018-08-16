from selenium import webdriver
from browsermobproxy import Server

def start_server(path):
	server = Server(path)
	server.start()
	return server

def create_proxy(server):
	proxy = server.create_proxy()
	return proxy

def set_profile(proxy):
	profile = webdriver.FirefoxProfile()
	profile.set_proxy(proxy.selenium_proxy())
	return profile

def start_har(proxy, name):
	proxy.new_har(name)

def check_har(proxy, string):
	print "Requests were made to the following URLS (displaying only the ones containing " +string+ " ):"
	print "="*(81+len(string))
	for entry in proxy.har['log']['entries']:
		if  string in entry['request']['url']:
			print entry['request']['url']+"\n"

def stop_server(server):
	server.stop()
	##driver = webdriver.Firefox(firefox_profile=profile)
	##proxy.new_har("cineworld")
	##driver.get("https://www.cineworld.co.uk/")




