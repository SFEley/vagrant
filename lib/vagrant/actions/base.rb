module Vagrant
  module Actions
    # Base class for any command actions. A command action handles
    # executing a step or steps on a given Vagrant::VM object. The
    # action should define any callbacks that it will call, or
    # attach itself to some callbacks on the VM object.
    class Base
      attr_reader :runner

      # Included so subclasses don't need to include it themselves.
      include Vagrant::Util

      # Initialization of the actions are done all at once. The guarantee
      # is that when an action is initialized, no other action has had
      # its `prepare` or `execute!` method called yet, so an action can
      # setup anything it needs to with this safety. An example of this
      # would be instance_evaling the vm instance to include a module so
      # additionally functionality could be defined on the vm which other
      # action `prepare` methods may rely on.
      def initialize(runner, *args)
        @runner = runner
      end

      # This method is called once per action, allowing the action
      # to setup any callbacks, add more events, etc. Prepare is
      # called in the order the actions are defined, and the action
      # itself has no control over this, so no race conditions between
      # action setups should be done here.
      def prepare
        # Examples:
        #
        # Perhaps we need an additional action to go, specifically
        # maybe only if a configuration is set
        #
        #@vm.actions << FooAction if Vagrant.config[:foo] == :bar
      end

      # This method is called once, after preparing, to execute the
      # actual task. This method is responsible for calling any
      # callbacks. Adding new actions here will have NO EFFECT, and
      # adding callbacks has unpredictable effects.
      def execute!
        # Example code:
        #
        # @vm.invoke_callback(:before_oven, "cookies")
        # Do lots of stuff here
        # @vm.invoke_callback(:after_oven, "more", "than", "one", "option")
      end

      # This method is called after all actions have finished executing.
      # It is meant as a place where final cleanup code can be done, knowing
      # that all other actions are finished using your data.
      def cleanup; end

      # This method is only called if some exception occurs in the chain
      # of actions. If an exception is raised in any action in the current
      # chain, then every action part of that chain has {#rescue} called
      # before raising the exception further. This method should be used to
      # perform any cleanup necessary in the face of errors.
      #
      # **Warning:** Since this method is called when an exception is already
      # raised, be _extra careful_ when implementing this method to handle
      # all your own exceptions, otherwise it'll mask the initially raised
      # exception.
      def rescue(exception); end
    end

    class ActionException < Exception; end
  end
end