
require 'monitor'

module Lore

  # To wrap database interaction in a transaction block, just use: 
  #
  #   Transaction.exec { |tx|
  #
  #       c1 = Car.create(:name => 'Ford Convertible')
  #       tx.save
  # 
  #       # You can savely nest transactions (i.e. 
  #       # reentrant transactions are okay): 
  #       Transaction.exec { |tx2|
  #         c2 = Car.create(:name => 'BMW Z5')
  #       }
  #
  #       raise Exception.new('rollback to last savepoint')
  #
  #       # c1 still is in DB, c2 is not. 
  #   }
  #
  # Using the block variable, you can trigger rollbacks, commits 
  # and savepoints yourself. 
  # This can be handy, but also dangerous. 
  #
  #   Transaction.exec { |tx|
  #       c1 = Car.create(:name => 'Ford Convertible')
  #       tx.rollback # c1 is gone now
  #       c2 = Car.create(:name => 'Ford Convertible')
  #       tx.commit # Careful: You are now outside of the transaction! 
  #
  #       # This call is not within a transaction
  #       c3 = Car.create(:name => 'Ford Convertible')
  #
  #       tx.begin # Now another transaction is started. 
  #       # So this call is 'secure' again. 
  #       c4 = Car.create(:name => 'Ford Convertible')
  #   }
  #
  #
  class Transaction

    attr_reader :context, :depth
    attr_reader :on_rollback, :on_commit, :last_savepoint

    def initialize
      Thread.current['lore_tx'] = [] unless Thread.current['lore_tx']

      wrapping_tx     = current_transaction()
      @depth          = 0 
      @depth          = (wrapping_tx.depth + 1) if wrapping_tx
      @context        = Context.current
      @on_rollback    = []
      @on_commit      = []
      @finalized      = true
      @committed      = false
      @parent_tx      = wrapping_tx
      @monitor        = Monitor.new
      @last_savepoint = false
    end

    def finalized?
      @finalized
    end

    def self.exec(&tx_block)
      tx = Transaction.new()
      begin
        tx.begin
        result = yield(tx)
        tx.commit
      rescue ::Exception => e
        tx.rollback
        raise e
      end
    end

    # Activates transaction. 
    def begin
      @finalized = false
      @monitor.synchronize { 
        Connection.begin_transaction(self) unless depth > 0
      }
      @monitor.synchronize { Thread.current['lore_tx'].push(self) }
    end

  private

    def current_transaction
      Thread.current['lore_tx'].last
    end

  public

#   def depth
#     Thread.current['lore_tx'].length
#   end

    # Removes current (this) transaction from 
    # Lore's transaction stack. 
    # A finalized transaction does not interact with 
    # the database. 
    def finalize
      @monitor.synchronize { 
        @finalized = true
        # Current transaction is always at the end of 
        # transaction list: 
        if Thread.current['lore_tx'][-1] == self then
          Thread.current['lore_tx'].delete_at(-1)
        end
        Thread.current['lore_tx'].each { |tx|
          tx.finalize unless tx.finalized?
        } 
        Thread.current['lore_tx'] = []
      }
    end

    def on_rollback(&block)
      @on_rollback.push(block)
    end

    def on_commit(&block)
      @on_commit.push(block)
    end

    def commit
      if Thread.current['lore_tx'][0] == self then
        @monitor.synchronize { 
          Connection.commit_transaction(self) unless @comitted
        }
        finalize
      end
      @on_commit.each { |block|
        block.call
      }
      @committed = true
      @parent_transaction.commit if @parent_transaction 
    end

    def rollback
      @monitor.synchronize { 
        Connection.rollback_transaction(self) unless @finalized
      }
      @on_rollback.each { |block|
        block.call
      }
      finalize
      @parent_transaction.rollback if @parent_transaction 
    end

    # Creates a savepoint. 
    def save
      @last_savepoint = Connection.add_savepoint(self)
    end

  end
end
