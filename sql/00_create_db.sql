-- Active: 1767454315925@@127.0.0.1@5433@crm_erp_dwh
/*
===========================================================
Script: create_db.sql
Descrição: Script para criar o database e schemas do Data Warehouse CRM/ERP
Autor: Edivan Carvalho
Data: 2026-01-02
===========================================================
*/
CREATE DATABASE crm_erp_dwh;
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;