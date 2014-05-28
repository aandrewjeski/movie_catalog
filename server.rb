require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

    yield(connection)

  ensure
    connection.close
  end
end

get "/" do
end

get "/actors" do
  @actors = nil
  db_connection do |conn|
    @actors = conn.exec('SELECT * FROM actors ORDER BY name LIMIT 20;')
  end
  @actors = @actors.to_a
  erb :actors
end

get "/actors/:id" do
  id = params[:id]

  db_connection do |conn|
    @actor_info = conn.exec_params(
      'SELECT actor.name AS name, movies.title AS movie, cast_members.character
      FROM actors
      JOIN cast_members ON actors.id = cast_members.actor_id
      JOIN movies ON cast_members.movie_id = movies.id
      WHERE actors.id = #{params[:id]};')
  end
  @actor_info = @actor_info.to_a
  erb :actor_info
end

get "/movies" do
  @movies = nil
  db_connection do |conn|
    @movies = conn.exec(
      'SELECT movies.title AS movie, movies.year AS year, movies.rating AS rating,
      genres.name AS genre, studios.name AS studio
      FROM movies
      JOIN genres ON movies.genre_id = genres.id
      JOIN studios ON movies.studio_id = studios.id
      LIMIT 20;')
  end
  @movies = @movies.to_a
  erb :movies
end

get "/movies/:id" do
  id = params[:id]

  db_connection do |conn|
  conn.exec_params('SELECT movies.title AS movie, movies.year AS year, movies.rating AS rating,
      genres.name AS genre, studios.name AS studio
      FROM movies
      JOIN genres ON movies.genre_id = genres.id
      JOIN studios ON movies.studio_id = studios.id
      LIMIT 20;')
    FROM movies WHERE id = $1, [id])
  end
  erb :movie_info
end
