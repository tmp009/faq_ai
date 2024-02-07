require 'dotenv/load'
require "openai"
require 'httparty'

class QuestionController < ApplicationController
    @@client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"))
    
    def perform
        faq_data = HTTParty.get('https://public.bc.fi/s2200767/faqai/faq.txt')

        response = @@client.chat(
            parameters: {
                model: "gpt-4",
                messages: [
                    { role: "system", content: "You will answer the users question only using the FAQ given to you. Do not use any other information"}, 
                    { role: "system", content: "Here's the FAQ: #{faq_data.body}"}, 
                    { role: "user", content: params[:prompt]}],
                temperature: 0.7,
            })
        
        flash[:response] = response.dig("choices", 0, "message", "content") 

        redirect_to home_path
    end
end
