require 'thread'

module EventQueue
  Rule=Struct.new(:name,:proc)
  Event=Struct.new(:name,:data)

  @@eventMutex=Mutex.new
  def event(name,*data)
    initEventQueue
    @@eventMutex.synchronize {
      @events<<Event.new(name,data)
    }
  end
  
  def self.included(model)
    model.class_eval do
    
    
      def self.rule(name,&proc)
        @@eventRules||=[]
        rule=Rule.new(name,proc)
        @@eventRules<<rule
      end
      
    end
  end
  
  def eventStep
    initEventQueue
    event=nil
    @@eventMutex.synchronize {
      event=@events.shift
    }
    if event
      rules=@@eventRules.select{|rule|
        rule.name==event.name
      }
      puts "No Rule found for #{event.name} in #{self}" if rules.length==0
      rules.each{|rule|
        instance_exec(*event.data, &rule.proc)
      }
    end
  end
  
  def initEventQueue
    @@eventMutex.synchronize {
      @events||=[]
    }
  end
end