# streamlit_app_spotify
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




