# streamlit_app_spotify

import streamlit as st 
from supabase import create_client

# Load credentials from secrets
url = st.secrets["SUPABASE_URL"]
key = st.secrets["SUPABASE_KEY"]
# Create client
supabase = create_client(url, key)
# Example: fetch all rows from "users" table
data = supabase.table("artist").select("*").execute()
st.write(data.data)
