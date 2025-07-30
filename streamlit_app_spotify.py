# streamlit_app_spotify
SUPABASE_URL = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3ZG5ndGd4ZGNwYWp2c25rbXd0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1NDU3NzAsImV4cCI6MjA2OTEyMTc3MH0.No0l-UlW0EV-qrxB6YhwRh-XZqwL7TDJSNJ0W13Pi0M"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3ZG5ndGd4ZGNwYWp2c25rbXd0Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzU0NTc3MCwiZXhwIjoyMDY5MTIxNzcwfQ.3foGFNYZ7stzqowjPG3KD5OSJHx4pDn3YEKR5PkJziU"

import streamlit as st
from st_supabase_connection import SupabaseConnection

        # Initialize connection
conn = st.connection(
            name="supabase",
            type=SupabaseConnection,
            url=st.secrets["SUPABASE_URL"],
            key=st.secrets["SUPABASE_KEY"]
        )

        # Example: Perform a query
response = conn.query("*", table="artist").execute()

        # Display results
if response and response.data:
            st.write("Data from Supabase:")
            st.dataframe(response.data)
else:
            st.write("No data retrieved or query failed.")




