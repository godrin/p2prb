require 'thread'

module SteppingJobQueue
  @@queueMutex=Mutex.new
  def enqueue(&job)
    initQueue
    @@queueMutex.synchronize {
      @queue<<job
    }
  end
  
  def jobStep
    initQueue
    job=nil
    @@queueMutex.synchronize {
      job=@queue.shift
    }
    if job
      job.call
    end
  end
  
  def initQueue
    @@queueMutex.synchronize {
      @queue||=[]
    }
  end
end