class Song

  attr_accessor :name, :album, :id

  def initialize(name:, album:, id: nil)
    @id = id
    @name = name
    @album = album
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS songs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
    SQL

    # insert the song
    DB[:conn].execute(sql, self.name, self.album)

    # get the song ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

    # return the Ruby instance
    self
  end

  def self.create(name:, album:)
    song = Song.new(name: name, album: album)
    song.save
  end
  
  # retrieves data from our database 
  def self.new_from_db(row)
    # self.new is equivalent to Song.new
    # the method reads data from SQlite and temporarily represents it in Ruby.
   self.new(id: row[0], name: row[1], album: row[2])
  end

  # Returns all songs in our database
   def self.all
     sql = <<-SQL
     SELECT * FROM songs
     SQL
    #  returns an array of rows,iterate using self.map method to create new ruby objects for each row
     DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
     end
  end

  # The song.find_by_name
  def self.find_by_name(name)
  sql = <<-SQL
  SELECT * FROM songs
  WHERE name = ?
  LIMIT 1
  SQL

  DB[:conn].execute(sql, name).map do |row|
    self.new_from_db(row)
  end.first
  end

end
