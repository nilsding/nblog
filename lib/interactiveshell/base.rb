require_relative './helpers'

# Hash containing all commands and their classes
IS_CMDS = {}

# Class that defines a command for NBlog::InteractiveShell.
class InteractiveShellCommand
  attr_reader :name
  attr_reader :args
  attr_reader :related

  def initialize
    @related = []
    @args = { required: [], optional: [] }
    @arg_str = ''
  end

  def create(name, &block)
    raise "Command #{name} already exists" if IS_CMDS.include? name
    @name = name
    instance_eval(&block)
    IS_CMDS[name] = self
  end

  # Sets the related commands.
  # @param cmdlist [Array] The related commands as symbols.
  def related_commands(*cmdlist)
    @related = cmdlist
  end

  # @param name [Symbol] The name of the argument as symbol.
  # @param type [Symbol] The type of the argument (:required (default) or
  # :optional)
  def argument(name, type = :required)
    raise "Argument #{name} already exists" if @args[type].include? name
    @args[type] << name
  end

  def main(&block)
    @main_action = block
  end

  def execute(args_str = '')
    @args_str = args_str
    instance_eval(&@main_action)
  end

  def help_text(&block)
    @help_action = block
  end

  def help
    puts NBlog::InteractiveShell::Helpers.usage @name, @args
    instance_eval(&@help_action)
    return if @related.empty?
    puts NBlog::InteractiveShell::Helpers.related_cmds @related
  end

  # @param text [String] The text to be printed
  # @param options [Hash] Options: :style, :newline (true/false)
  def line(text, options = {})
    options = { style: :default, newline: true }.merge(options)
    case options[:style]
    when :danger
      n_puts options[:newline], HighLine.color(text, HighLine::RED,
                                               HighLine::BOLD)
    when :underline
      n_puts options[:newline], HighLine.color(text, HighLine::UNDERLINE)
    else
      n_puts options[:newline], text
    end
  end

  def sql(message, sql_str, bind_vars)
    NBlog::InteractiveShell::Helpers.run_sql(message, sql_str, bind_vars, false)
  end

  def sql_batch(message, sql_str, bind_vars)
    NBlog::InteractiveShell::Helpers.run_sql(message, sql_str, bind_vars, true)
  end

  def to_s
    "#<InteractiveShellCommand #{@name}>"
  end

  private

  attr_reader :main_action
  attr_reader :help_action
  attr_reader :arg_str

  def n_puts(newline, text)
    if newline
      puts text
    else
      print text
    end
  end
end
