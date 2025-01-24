#!/bin/bash

DB_PATH="$1"

if [ ! -d "$DB_PATH" ]; then
    echo "Invalid database path. Exiting."
    exit 1
fi

while true; do
    echo "Table Management in $(basename "$DB_PATH")"
    echo "1. Create Table"
    echo "2. List Tables"
    echo "3. Drop Table"
    echo "4. Insert Row"
    echo "5. Show Data"
    echo "6. Delete Row"
    echo "7. Update Cell"
    echo "8. Search in table"
    echo "9. Exit"
    read -p "Choose an option: " choice

    case $choice in
    1)
        read -p "Enter table name: " tablename
        if [[ "$tablename" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
            if [ -f "$DB_PATH/$tablename" ]; then
                echo "Table '$tablename' already exists."
            else
                read -p "Enter column names (comma-separated): " columns
                echo "$columns" >"$DB_PATH/$tablename"
                echo "Table '$tablename' created successfully."
            fi
        else
            echo "Invalid table name. Avoid special characters and numbers at the start."
        fi
        ;;
    2)
        echo "Available Tables:"
        ls "$DB_PATH"
        ;;
    3)
        read -p "Enter table name to drop: " tablename
        if [ -f "$DB_PATH/$tablename" ]; then
            read -p "Are you sure you want to delete table '$tablename'? (y/n): " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                rm "$DB_PATH/$tablename" && echo "Table '$tablename' deleted successfully."
            fi
        else
            echo "Table '$tablename' does not exist."
        fi
        ;;
    4)
    read -p "Enter table name to insert row: " tablename
    if [ -f "$DB_PATH/$tablename" ]; then
        columns=$(head -n 1 "$DB_PATH/$tablename")
        IFS=',' read -ra col_arr <<<"$columns"
        row=""
        is_duplicate=false

        for i in "${!col_arr[@]}"; do
            col=${col_arr[i]}

            if [ $i -eq 0 ]; then
                # Ensure unique ID for the first column
                while true; do
                    read -p "Enter value for $col (must be unique): " value
                    if grep -q "^$value," "$DB_PATH/$tablename"; then
                        echo "Error: ID already exists. Please enter a unique ID."
                    else
                        row+="$value,"
                        break
                    fi
                done
            else
                read -p "Enter value for $col: " value
                row+="$value,"
            fi
        done

        row=${row%,} # Remove trailing comma
        echo "$row" >>"$DB_PATH/$tablename"
        echo "Row inserted successfully."
    else
        echo "Table '$tablename' does not exist."
    fi
    ;;
    
    5)
        read -p "Enter table name to view data: " tablename
        if [ -f "$DB_PATH/$tablename" ]; then
            cat "$DB_PATH/$tablename"
        else
        
            echo "Table '$tablename' does not exist."
        fi
        ;;
    6)
    read -p "Enter table name to delete a row: " tablename
    if [ -f "$DB_PATH/$tablename" ]; then
        echo "Table Data:"
        nl -s ". " "$DB_PATH/$tablename" | column -t -s ','
        read -p "Enter row number to delete (starting from 2): " row_number
        if [[ "$row_number" =~ ^[0-9]+$ ]] && [ "$row_number" -ge 2 ]; then
            sed -i "${row_number}d" "$DB_PATH/$tablename" && echo "Row $row_number deleted successfully." || echo "Error deleting row."
        else
            echo "Invalid row number."
        fi
    else
        echo "Table '$tablename' does not exist."
    fi
    ;;
    
   
    7)
    read -p "Enter table name to update a cell: " tablename
    if [ -f "$DB_PATH/$tablename" ]; then
        echo "Table Data:"
        nl -s ". " "$DB_PATH/$tablename" | column -t -s ','
        read -p "Enter row number to update (starting from 2): " row_number
        read -p "Enter column number to update (starting from 2): " col_number
        
        # Prevent updating the ID column (first column)
        if [ "$col_number" -eq 1 ]; then
            echo "Error: Updating the ID column is not allowed."
            break
        fi
        
        read -p "Enter new value: " new_value

        if [[ "$row_number" =~ ^[0-9]+$ ]] && [[ "$col_number" =~ ^[0-9]+$ ]] && [ "$row_number" -ge 2 ]; then
            old_row=$(sed -n "${row_number}p" "$DB_PATH/$tablename")
            if [ -n "$old_row" ]; then
                IFS=',' read -ra row_data <<<"$old_row"
                if [ "$col_number" -le "${#row_data[@]}" ]; then
                    row_data[$((col_number - 1))]="$new_value"
                    new_row=$(IFS=','; echo "${row_data[*]}")
                    sed -i "${row_number}s/.*/$new_row/" "$DB_PATH/$tablename" && echo "Cell updated successfully." || echo "Error updating cell."
                else
                    echo "Invalid column number."
                fi
            else
                echo "Invalid row number."
            fi
        else
            echo "Invalid input. Row number must be 2 or higher."
        fi
    else
        echo "Table '$tablename' does not exist."
    fi
    ;;
    8)
    # Call the Search Function
    read -p "Enter table name to search: " tablename
    if [ -f "$DB_PATH/$tablename" ]; then
        columns=$(head -n 1 "$DB_PATH/$tablename")
        IFS=',' read -ra col_arr <<<"$columns"
        echo "Columns: ${col_arr[*]}"
        read -p "Enter column name to search: " col_name
        read -p "Enter value to search for: " search_value

        col_index=-1
        for i in "${!col_arr[@]}"; do
            if [ "${col_arr[$i]}" == "$col_name" ]; then
                col_index=$i
                break
            fi
        done

        if [ $col_index -eq -1 ]; then
            echo "Column '$col_name' does not exist."
        else
            echo "Search Results:"
            awk -F, -v idx=$((col_index + 1)) -v val="$search_value" 'NR == 1 || $idx == val' "$DB_PATH/$tablename" | column -t -s ','
        fi
    else
        echo "Table '$tablename' does not exist."
    fi
    ;;
9)
        echo "Returning to database menu..."
        break
        ;;
    *)
        echo "Invalid option. Please try again."
        ;;
    esac
done
