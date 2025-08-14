defmodule BasicApp.DatabaseSetup do
  @moduledoc """
  Handles database setup during application startup.
  Creates database and runs migrations if needed.
  """

  require Logger

  @doc """
  Ensures the database exists and runs migrations.
  This is called during application startup.
  """
  def setup! do
    Logger.info("Starting database setup...")
    
    # Create database if it doesn't exist
    create_database_if_needed()
    
    # Run migrations
    migrate_database()
    
    Logger.info("Database setup completed successfully")
  end

  defp create_database_if_needed do
    Logger.info("Ensuring database exists...")
    
    case BasicApp.Repo.__adapter__().storage_up(BasicApp.Repo.config()) do
      :ok ->
        Logger.info("Database created successfully")
        
      {:error, :already_up} ->
        Logger.info("Database already exists")
        
      {:error, term} ->
        Logger.error("Failed to create database: #{inspect(term)}")
        raise "Database creation failed: #{inspect(term)}"
    end
  end

  defp migrate_database do
    Logger.info("Running database migrations...")
    
    # Get the path to migrations
    migrations_path = Application.app_dir(:basic_app, "priv/repo/migrations")
    
    case Ecto.Migrator.run(BasicApp.Repo, migrations_path, :up, all: true) do
      {:ok, migrations} ->
        if length(migrations) > 0 do
          Logger.info("Ran #{length(migrations)} migration(s)")
        else
          Logger.info("No migrations to run")
        end
        
      # Handle case where migrations return empty list (no migrations exist)
      [] ->
        Logger.info("No migrations found - database is ready")
        
      {:error, error} ->
        Logger.error("Migration failed: #{inspect(error)}")
        raise "Migration failed: #{inspect(error)}"
    end
  end
end
