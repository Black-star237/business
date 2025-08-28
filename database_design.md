database Structure Overview

Below is a concise description of every schema, its tables, key columns, and relationships in your project.

auth schema
Tables

users – primary key id (UUID). Handles authentication data. Columns include instance_id, aud, role, email, encrypted_password, timestamps, raw_user_meta_data, is_super_admin, etc.
refresh_tokens – primary key id (bigint). Columns: token, user_id, revoked, timestamps, session_id.
instances – primary key id (UUID). Columns: uuid, raw_base_config, timestamps.
audit_log_entries – primary key id (UUID). Columns: instance_id, payload, created_at, ip_address.
schema_migrations – primary key version (text). Tracks auth migrations.
identities – primary key id (UUID). Columns: provider_id, user_id, identity_data, provider, timestamps, generated email.
sessions – primary key id (UUID). Columns: user_id, created_at, updated_at, factor_id, aal, not_after, user_agent, ip, tag.
mfa_factors – primary key id (UUID). Columns: user_id, friendly_name, factor_type, status, timestamps, secret data, phone, etc.
mfa_challenges – primary key id (UUID). Columns: factor_id, timestamps, verified_at, otp_code, web_authn_session_data.
mfa_amr_claims – primary key id (UUID). Columns: session_id, created_at, updated_at, authentication_method.
sso_providers – primary key id (UUID). Columns: resource_id, timestamps, disabled.
sso_domains – primary key id (UUID). Columns: sso_provider_id, domain, timestamps.
saml_providers – primary key id (UUID). Columns: sso_provider_id, entity_id, metadata_xml, attribute_mapping, timestamps.
saml_relay_states – primary key id (UUID). Columns: sso_provider_id, request_id, for_email, redirect_to, timestamps, flow_state_id.
flow_state – primary key id (UUID). Columns: user_id, auth_code, PKCE fields, timestamps, authentication_method.
one_time_tokens – primary key id (UUID). Columns: user_id, token_type, token_hash, timestamps, relates_to.
Relationships

identities.user_id → auth.users.id
sessions.user_id → auth.users.id
refresh_tokens.session_id → auth.sessions.id
mfa_factors.user_id → auth.users.id
mfa_challenges.factor_id → auth.mfa_factors.id
mfa_amr_claims.session_id → auth.sessions.id
sso_domains.sso_provider_id → auth.sso_providers.id
saml_providers.sso_provider_id → auth.sso_providers.id
saml_relay_states.sso_provider_id → auth.sso_providers.id
saml_relay_states.flow_state_id → auth.flow_state.id
one_time_tokens.user_id → auth.users.id
public schema
Core Tables

profiles – primary key id (UUID, FK to auth.users.id). Columns: email (unique), first_name, last_name, phone, avatar_url, position, is_active, timestamps.
permissions – primary key id (UUID). Columns: user_id (FK to profiles.id), module, action, granted_by (FK to profiles.id), timestamps.
Business Tables
categories – primary key id (UUID). Columns: name, description, parent_id (FK to categories.id), image_url, sort_order, is_active, timestamps, company_id.
suppliers – primary key id (UUID). Columns: name, email, phone, address, contact info, payment_terms, is_active, timestamps, company_id.
products – primary key id (UUID). Columns: name, description, sku (unique), barcode (unique), category_id (FK to categories.id), supplier_id (FK to suppliers.id), pricing fields, stock fields, unit, tax_rate, image_url, is_active, has_variants, timestamps, company_id, price range fields.
product_variants – primary key id (UUID). Columns: product_id (FK to products.id), name, sku (unique), barcode (unique), pricing, current_stock, timestamps.
stock_movements – primary key id (UUID). Columns: product_id (FK to products.id), variant_id (FK to product_variants.id), movement_type (enum), quantity, unit_cost, reference fields, notes, created_by (FK to profiles.id), timestamps.
inventory_alerts – primary key id (UUID). Columns: product_id (FK to products.id), alert_type, threshold_value, is_resolved, resolved_by (FK to profiles.id), timestamps, company_id.
clients – primary key id (UUID). Columns: contact info, tax number, type, credit limit, payment terms, activity flag, purchase stats, created_by (FK to profiles.id), timestamps, company_id.
client_addresses – primary key id (UUID). Columns: client_id (FK to clients.id), address fields, is_default, timestamps.
client_notes – primary key id (UUID). Columns: client_id (FK to clients.id), note, type, importance flag, created_by (FK to profiles.id), timestamps.
client_categories – primary key id (UUID). Columns: name (unique), description, discount, timestamps.
sales – primary key id (UUID). Columns: sale_number (unique), client_id (FK to clients.id), financial totals, payment_method (enum), status (enum), notes, sold_by (FK to profiles.id), sale_date, timestamps, company_id.
sale_items – primary key id (UUID). Columns: sale_id (FK to sales.id), product_id (FK to products.id), variant_id (FK to product_variants.id), quantity, pricing, taxes, line total, timestamps, invoice_id (FK to invoices.id).
invoices – primary key id (UUID). Columns: invoice_number (unique), sale_id (FK to sales.id), client_id (FK to clients.id), issue/due dates, amounts, status (enum), payment_terms, notes, created_by (FK to profiles.id), timestamps, company_id.
payments – primary key id (UUID). Columns: invoice_id (FK to invoices.id), sale_id (FK to sales.id), amount, payment_method (enum), payment_date, reference_number, notes, processed_by (FK to profiles.id), timestamps.
promotions – primary key id (UUID). Columns: name, description, promotion_type (enum), value, purchase thresholds, dates, active flag, usage limits, applied categories/products (UUID arrays), created_by (FK to profiles.id), timestamps, company_id.
daily_stats – primary key id (UUID). Columns: stat_date (unique), totals for sales, transactions, items sold, average sale value, new clients, profit, timestamps, company_id.
monthly_reports – primary key id (UUID). Columns: report_month (date), revenue, profit, sales count, new clients, top-selling products (JSONB), revenue by category (JSONB), timestamps, company_id.
kpi_metrics – primary key id (UUID). Columns: metric_name, metric_value, metric_date, category, timestamps, company_id.
tax_rates – primary key id (UUID). Columns: name, rate, is_default, is_active, timestamps.
currencies – primary key id (UUID). Columns: code (unique), name, symbol, exchange_rate, is_default, timestamps.
ai_conversations – primary key id (UUID). Columns: user_id (FK to profiles.id), title, context_data (JSONB), is_active, timestamps, company_id.
ai_messages – primary key id (UUID). Columns: conversation_id (FK to ai_conversations.id), role, content, metadata (JSONB), timestamps.
file_uploads – primary key id (UUID). Columns: filename, original_filename, file_size, mime_type, storage_path, uploaded_by (FK to profiles.id), entity_type, entity_id, is_public, timestamps.
product_images – primary key id (UUID). Columns: product_id (FK to products.id), file_id (FK to file_uploads.id), is_primary, sort_order, timestamps.
companies – primary key id (UUID). Columns: name, description, logo_url, contact info, tax number, default currency, timezone, default tax rate, fiscal year start, subscription plan/status, expiration, settings (JSONB), active flag, created_by (FK to profiles.id), timestamps.
company_members – primary key id (UUID). Columns: company_id (FK to companies.id), user_id (FK to auth.users.id), role (enum), permissions (JSONB), is_active, joined_at, invited_by.
user_roles – primary key id (UUID). Columns: user_id (FK to auth.users.id), role (enum), timestamps.
notifications – primary key id (UUID). Columns: type (enum), title, description, read, createdAt, userId (FK to auth.users.id), companyid (FK to companies.id), priority (enum), metadata (JSONB).
companies_invitations – primary key id (UUID). Columns: email, company_id (FK to companies.id), role, token (unique), expires_at, timestamps.
companies_join_requests – primary key id (UUID). Columns: user_id (FK to auth.users.id), companies_id (FK to companies.id), status, timestamps.
Key Relationships

profiles.id → auth.users.id (one‑to‑one).
permissions.user_id → profiles.id; permissions.granted_by → profiles.id.
categories.parent_id → categories.id.
products.category_id → categories.id; products.supplier_id → suppliers.id.
product_variants.product_id → products.id.
stock_movements.product_id → products.id; stock_movements.variant_id → product_variants.id; stock_movements.created_by → profiles.id.
inventory_alerts.product_id → products.id; inventory_alerts.resolved_by → profiles.id.
clients.created_by → profiles.id.
client_addresses.client_id → clients.id.
client_notes.client_id → clients.id; client_notes.created_by → profiles.id.
sales.client_id → clients.id; sales.sold_by → profiles.id.
sale_items.sale_id → sales.id; sale_items.product_id → products.id; sale_items.variant_id → product_variants.id; sale_items.invoice_id → invoices.id.
invoices.sale_id → sales.id; invoices.client_id → clients.id; invoices.created_by → profiles.id.
payments.invoice_id → invoices.id; payments.sale_id → sales.id; payments.processed_by → profiles.id.
promotions.created_by → profiles.id.
ai_conversations.user_id → profiles.id; ai_messages.conversation_id → ai_conversations.id.
file_uploads.uploaded_by → profiles.id.
product_images.product_id → products.id; product_images.file_id → file_uploads.id.
companies.created_by → profiles.id.
company_members.company_id → companies.id; company_members.user_id → auth.users.id.
user_roles.user_id → auth.users.id.
notifications.userId → auth.users.id; notifications.companyid → companies.id.
companies_invitations.company_id → companies.id.
companies_join_requests.user_id → auth.users.id; companies_join_requests.companies_id → companies.id.
storage schema
Tables

buckets – primary key id (text). Columns: name, owner (deprecated), timestamps, public, avif_autodetection, size limits, allowed MIME types, owner_id (text), type (enum STANDARD/ANALYTICS).
objects – primary key id (UUID). Columns: bucket_id (FK to buckets.id), name, owner (deprecated), timestamps, metadata (JSONB), path_tokens (generated), version, owner_id (text), user_metadata (JSONB), level.
migrations – primary key id (integer). Tracks storage migrations.
s3_multipart_uploads – primary key id (text). Columns: in_progress_size, upload_signature, bucket_id (FK), key, version, owner_id, timestamps, user_metadata (JSONB).
s3_multipart_uploads_parts – primary key id (UUID). Columns: upload_id (FK), size, part_number, bucket_id (FK), key, etag, owner_id, version, timestamps.
prefixes – composite primary key (bucket_id, name, level). Columns: timestamps.
Relationships

objects.bucket_id → buckets.id.
s3_multipart_uploads.bucket_id → buckets.id.
s3_multipart_uploads_parts.upload_id → s3_multipart_uploads.id.
s3_multipart_uploads_parts.bucket_id → buckets.id.
prefixes.bucket_id → buckets.id.
realtime schema
Tables

subscription – primary key id (bigint, identity). Columns: subscription_id (UUID), entity (regclass), filters (array), claims (JSONB), claims_role, timestamps.
messages – primary key id (UUID). Columns: topic, extension, payload (JSONB), event, private (bool), timestamps.
schema_migrations – primary key version (bigint). Tracks realtime migrations.
Time‑partitioned message tables (messages_YYYY_MM_DD) – same structure as messages, used internally for storage efficiency.

extensions schema
No user‑defined tables at present (holds installed extensions).
supabase_migrations schema
Table
schema_migrations – primary key version (text). Holds migration history for Supabase.
pgbouncer schema
No user tables (used for connection pooling).
Summary
Your database includes:

Auth tables for user management and security.
Public tables covering core business entities (profiles, products, orders, inventory, finance, CRM, analytics, AI chat, files, companies, notifications, etc.).
Storage tables for object/bucket management.
Realtime tables for change‑feed subscriptions and partitioned message logs.
All tables have appropriate primary keys, foreign key relationships, and most support Row‑Level Security (RLS) where enabled. This structure should give you a solid foundation for building queries, APIs, and Edge Functions against your Supabase project.