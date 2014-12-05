class RlngsController < ApplicationController
	def index
	end
	def run
		require "rinruby" #加载rinruby库
		@Rtest=params[:Rtest]#接收名为Rtest的值
		@Rtest=@Rtest.gsub("\r\n",";") #这里把接收到的R语句的回车变为;号，如果要处理更复杂的R，这里需要想更多的办法。
		R.eval @Rtest#执行R脚本
	end

end