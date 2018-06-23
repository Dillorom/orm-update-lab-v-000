require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :name, :grade
  attr_reader :id

  @@all = []
  
  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
    @@all << self
  end

  def self.all 
    @@all 
  end
 
  def save
      if self.id
        self.update
      else
        sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.grade)
        @id = DB[:conn].execute("SELECT * FROM students")[0][0]
    end

    def self.create(name:, grade:)
      student = Student.new(name, grade)
      student.save
      student
    end

    def update
      sql = "UPDATE students SET name = ?, grade = ?, id = ?"
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end
  end


  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY key,
        name TEXT,
        grade INTEGER
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    new_student = self.new
    new_student.id = row[0]
    new_student.name = row[1]
    new_student.grade = row[2]
  end

  def self.find_by_name(name)
    self.all.detect {|a| a.name == name}
  end
end
