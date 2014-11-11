require 'etc'

module Rushed
  class File
    def initialize(path)
      @path = path
    end

    def basename
      delegate_to_file(:basename)
    end

    def ctime
      delegate_to_file(:ctime)
    end

    def extname
      delegate_to_file(:extname)
    end

    def format(format='l')
      separator = "\t"
      case format
      when 'l'
        datetime = ctime.strftime(%w{%Y-%m-%d %H:%M}.join(separator))
        return [omode, owner, group, size, datetime, name].join(separator)
      else
        raise 'format not supported'
      end
    end

    def ftype
      delegate_to_file(:ftype)
    end

    def gid
      delegate_to_stat(:gid)
    end

    def group
      Etc.getgrgid(gid).name
    end

    def mode
      delegate_to_stat(:mode)
    end

    def mtime
      delegate_to_file(:mtime)
    end

    def omode
      '%o' % world_readable?
    end

    def owner
      Etc.getpwuid(uid).name
    end

    def size
      delegate_to_file(:size)
    end

    def to_s
      name
    end

    def uid
      delegate_to_stat(:uid)
    end

    def world_readable?
      delegate_to_stat(:world_readable?)
    end

    def <=>(other)
      name <=> other.name
    end

    alias_method :name, :basename
    alias_method :created_at, :ctime
    alias_method :updated_at, :mtime

    private

    def delegate_to_file(method)
      ::File.send(method, @path)
    end

    def delegate_to_stat(method)
      ::File.stat(@path).send(method)
    end
  end
end
