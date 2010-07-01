require 'pp'

module P2P
class MEM
  class MyJob
    attr_reader :proc,:wait,:start_time
    def initialize(proc,wait,start_time)
      @proc=proc
      @wait=wait
      @start_time=start_time
    end
    
    def should_go?
      Time.now>go_time
    end
    
    def go_time
      start_time+wait
    end
  end


  class Runner
  
    def initialize
      @jobs=Queue.new # FIXME: exchange with priority queue
      @timed=[]
      @mutex=Mutex.new
      @started=false
      @timerThread=Thread.new { timerLoop }
      @thread=Thread.new {myloop}
      @sync_objects={}
    end
    def add(job)
      if job.should_go?
        @jobs<<job
      else
        add_timed(job)
      end
    end
      
    def myloop
      loop do
        job=@jobs.pop
        unless job.should_go?
          raise "Job should not yet be started !!!"
        else
          block=job.proc
          if block
            begin
              block.call
            rescue Object=>e
#              Logger::log(e)
pp e
if e.respond_to?(:backtrace)
pp e.backtrace
end
            end
          else
            sleep 0.010
          end
        end
      end
    end
   private
    def add_timed_intern(job)
      @mutex.synchronize {
        @timed<<job
        @timed.sort!{|a,b|a.go_time<=>b.go_time}
      }
    end
    def add_timed(job)
      add_timed_intern(job)
      @timerThread.wakeup if @started and @timerThread.alive?
    end
  
    def timerLoop
      @started=true
      pp "timer Loop stzartzed"
      begin
        loop do
          if @timed.length>0
            first=nil
            @mutex.synchronize {
              first=@timed.shift
            }
            diff=first.go_time-Time.now
            if diff<0
              add(first)
            else
              add_timed_intern(first)
              sleep diff
            end
          else
            sleep 10
          end
        end
      rescue Object>=e
        pp e
        pp "ERROR ???"
      rescue
        pp "klsdklsdfjklsdf"
      end
      pp "timer Loop ended"
    end
  end

    def self.enqueue(seconds_to_wait=0,&block)
      @@mem||=Runner.new
      @@mem.add(MEM::MyJob.new(block,seconds_to_wait,Time.now))
    end
  

  end
end