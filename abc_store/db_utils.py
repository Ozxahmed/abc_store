"""Database connection and export utilities for the ABC Store project."""

import os
from typing import Optional

import psycopg2
from psycopg2 import OperationalError
from dotenv import load_dotenv


def get_connection(dotenv_path: Optional[str] = None, verbose: bool = True):
    """Create and return a psycopg2 connection using environment variables.

    Expected env vars:
      - DB_NAME, DB_USER, DB_PASSWORD, DB_HOST, DB_PORT

    Args:
        dotenv_path: Path to a .env file. If None, load_dotenv() will search upward.
        verbose: Whether to print connection info (never prints password).

    Returns:
        psycopg2 connection or None if connection fails.
    """
    if dotenv_path:
        load_dotenv(dotenv_path)
    else:
        load_dotenv()  # searches for .env

    dbname = os.getenv("DB_NAME")
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    host = os.getenv("DB_HOST")
    port = os.getenv("DB_PORT")

    if verbose:
        print("--- CONNECTION ---\nConnecting using following settings:")
        print(f"DB_NAME: {dbname}")
        print(f"DB_USER: {user}")
        print(f"DB_HOST: {host}")
        print(f"DB_PORT: {port}")

    try:
        connection = psycopg2.connect(
            dbname=dbname,
            user=user,
            password=password,
            host=host,
            port=port,
        )
        if verbose:
            print("\nConnection successful!")
        return connection

    except OperationalError as e:
        print(f"Error connecting to database: {e}")
        return None
