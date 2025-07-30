import streamlit as st
import psycopg
from supabase import create_client, Client


try:
    url = st.secrets["supabase"]["SUPABASE_URL"]
    key = st.secrets["supabase"]["SUPABASE_KEY"]
except KeyError as e:
    st.error(f"Missing Supabase secret: {e}")
    st.stop() 


try:
    supabase = create_client(url, key)
except Exception as e:
    st.error(f"Failed to initialize Supabase client:\n{e}")
    st.stop()
