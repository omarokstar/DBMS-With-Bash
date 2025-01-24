#!/bin/bash

DB_DIR="./databases"

# Ensure the databases directory exists
mkdir -p "$DB_DIR"

# Main menu
while true; do
    echo "Database Management System"
    echo "1. Create Database"
    echo "2. List Databases"
    echo "3. Connect to Database"
    echo "4. Delete Database"
    echo "5. Exit"
    read -p "Choose an option: " choice

    case $choice in
    1) 
        read -p "Enter database name: " dbname
        if [[ "$dbname" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
            mkdir -p "$DB_DIR/$dbname" && echo "Database '$dbname' created successfully." || echo "Error creating database."
        else
            echo "Invalid database name. Avoid special characters and numbers at the start."
        fi
        ;;
    2) 
        echo "Available Databases:"
        ls "$DB_DIR"
        ;;
    3) 
        read -p "Enter database name to connect: " dbname
        if [ -d "$DB_DIR/$dbname" ]; then
            echo "Connected to '$dbname'."
            ./table.sh "$DB_DIR/$dbname"
        else
            echo "Database '$dbname' does not exist."
        fi
        ;;
    4) 
        read -p "Enter database name to delete: " dbname
        if [ -d "$DB_DIR/$dbname" ]; then
            read -p "Are you sure you want to delete '$dbname'? (y/n): " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                rm -rf "$DB_DIR/$dbname" && echo "Database '$dbname' deleted successfully."
            fi
        else
            echo "Database '$dbname' does not exist."
        fi
        ;;
    5) 
        echo "Exiting..."
        exit 0
        ;;
    *) 
        echo "Invalid option. Please try again."
        ;;
    esac
done
