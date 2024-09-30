import sqlite3
import pandas as pd


def fracture_identification():
    ''' This function identifies humerus and wrist fractures from PACS and register data. '''

    # connect to SQLite database
    conn = sqlite3.connect("register_and_pacs_data.db")

  
    ### HUMERUS FRACTURE IDENTIFICATION ###

    # Load and execute humerus PACS query
    with open("query_humerus_pacs.sql", 'r') as file:
        query_humerus_pacs = file.read()
      
    humerus_pacs_data = pd.read_sql_query(query_humerus_pacs, conn)
    print(f"Humerus examination series in PACS: {len(humerus_pacs_data)}")

    # Filter for PACS2+ fractures
    humerus_pacs_2plus = humerus_pacs_data[(humerus_pacs_data['pacs_exam_count'] >= 2) &
                                           (humerus_pacs_data['request_type'] != 'elective') &
                                           (humerus_pacs_data['exam_date'] != humerus_pacs_data['pacs_max_date'])]
    print(f"Humerus PACS2+ identified fractures: {len(humerus_pacs_2plus)}")

    # Filter for PACS3+ fractures
    humerus_pacs_3plus = humerus_pacs_data[(humerus_pacs_data['pacs_exam_count'] >= 3) &
                                           (humerus_pacs_data['request_type'] != 'elective') &
                                           (humerus_pacs_data['exam_date'] != humerus_pacs_data['pacs_max_date'])]
    print(f"Humerus PACS3+ identified fractures: {len(humerus_pacs_3plus)}")

    # Query for register data (with diagnosis code S42.2)
    with open("query_humerus_register.sql", 'r') as file:
        query_registers = file.read()
    humerus_register_data = pd.read_sql_query(query_registers, conn)
    print(f"Humerus register identified fractures: {len(humerus_register_data)}")

    # Filter for combined A fractures
    humerus_combined_a = humerus_register_data[humerus_register_data['pacs_exam_count'] >= 1]
    print(f"Humerus combined A identified fractures: {len(humerus_combined_a)}")

    # Modify query to include extended diagnosis codes
    query_registers_extended = query_registers.replace("'S422'", "'S422', 'S42', 'S423', 'L76'")
    humerus_register_data_extended = pd.read_sql_query(query_registers_extended, conn)

    # Filter for combined B fractures
    humerus_combined_b = humerus_register_data_extended[(humerus_register_data_extended['pacs_exam_count'] >= 2) |
                                                        ((humerus_register_data_extended['pacs_exam_count'] == 1) &
                                                         (humerus_register_data_extended['diagnosis_code'] == 'S422'))]
    print(f"Humerus combined B identified fractures: {len(humerus_combined_b)}")


    ### WRIST FRACTURE IDENTIFICATION ###

    # Load and execute wrist PACS query
    with open("query_wrist_pacs.sql", 'r') as file:
        query_wrist_pacs = file.read()

    wrist_pacs_data = pd.read_sql_query(query_wrist_pacs, conn)
    print(f"Wrist examination series in PACS: {len(wrist_pacs_data)}")

    # Filter for PACS2+ fractures
    wrist_pacs_2plus = wrist_pacs_data[wrist_pacs_data['pacs_exam_count'] >= 2]
    print(f"Wrist PACS2+ identified fractures: {len(wrist_pacs_2plus)}")

    # Filter for PACS3+ fractures
    wrist_pacs_3plus = wrist_pacs_data[wrist_pacs_data['pacs_exam_count'] >= 3]
    print(f"Wrist PACS3+ identified fractures: {len(wrist_pacs_3plus)}")

    # Query for wrist register data
    with open("query_wrist_register.sql", 'r') as file:
        query_wrist_register = file.read()
    wrist_register_data = pd.read_sql_query(query_wrist_register, conn)
    print(f"Wrist register identified fractures: {len(wrist_register_data)}")

    # Filter for combined A fractures
    wrist_combined_a = wrist_pacs_data[(wrist_pacs_data['pacs_exam_count'] >= 3) |
                                       ((wrist_pacs_data['pacs_exam_count'] == 2) &
                                        (wrist_pacs_data['register_contact_count'] > 0))]
    print(f"Wrist combined A identified fractures: {len(wrist_combined_a)}")

    # Filter for combined B register part
    wrist_combined_b_reg_part = wrist_register_data[(wrist_register_data['pacs_exam_count'] == 0) &
                                                    (wrist_register_data['register_contact_count'] >= 3)]

    wrist_combined_b_reg_part = wrist_combined_b_reg_part[['patient_id', 'index_date']]

    # Rename exam_date to index_date for combining
    wrist_combined_a = wrist_combined_a.rename(columns={'exam_date': 'index_date'})
    wrist_combined_a_part = wrist_combined_a[['patient_id', 'index_date']]

    # Combine parts
    wrist_combined_b = pd.concat([wrist_combined_b_reg_part, wrist_combined_a_part])
    print(f"Wrist combined B identified fractures: {len(wrist_combined_b)}")

  
    # Close the database connection
    conn.close()


if __name__ == '__main__':
    fracture_identification()
