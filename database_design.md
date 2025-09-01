1. auth schema
Tables

users

instance_id – uuid (nullable)
id – uuid PK (not null)
aud – varchar (nullable)
role – varchar (nullable)
email – varchar (nullable)
encrypted_password – varchar (nullable)
email_confirmed_at – timestamptz (nullable)
invited_at – timestamptz (nullable)
confirmation_token – varchar (nullable)
confirmation_sent_at – timestamptz (nullable)
recovery_token – varchar (nullable)
recovery_sent_at – timestamptz (nullable)
email_change_token_new – varchar (nullable)
email_change – varchar (nullable)
email_change_sent_at – timestamptz (nullable)
last_sign_in_at – timestamptz (nullable)
raw_app_meta_data – jsonb (nullable)
raw_user_meta_data – jsonb (nullable)
is_super_admin – boolean (nullable)
created_at – timestamptz (nullable)
updated_at – timestamptz (nullable)
phone – text unique (nullable)
phone_confirmed_at – timestamptz (nullable)
phone_change – text (nullable)
phone_change_token – varchar (nullable)
phone_change_sent_at – timestamptz (nullable)
confirmed_at – generated timestamptz (nullable)
email_change_token_current – varchar (nullable)
email_change_confirm_status – smallint default 0 (check 0‑2)
banned_until – timestamptz (nullable)
reauthentication_token – varchar (nullable)
reauthentication_sent_at – timestamptz (nullable)
is_sso_user – boolean default false (not null)
deleted_at – timestamptz (nullable)
is_anonymous – boolean default false (not null)
refresh_tokens

instance_id – uuid (nullable)
id – bigint PK (not null)
token – varchar unique (nullable)
user_id – uuid (nullable)
revoked – boolean (nullable)
created_at – timestamptz (nullable)
updated_at – timestamptz (nullable)
parent – varchar (nullable)
session_id – uuid (nullable)
instances

id – uuid PK (not null)
uuid – uuid (nullable)
raw_base_config – text (nullable)
created_at – timestamptz (nullable)
updated_at – timestamptz (nullable)
audit_log_entries

instance_id – uuid (nullable)
id – uuid PK (not null)
payload – json (nullable)
created_at – timestamptz (nullable)
ip_address – character varying not null, default ''
schema_migrations

version – character varying PK (not null)
identities

provider_id – text (not null)
user_id – uuid (not null)
identity_data – jsonb (not null)
provider – text (not null)
last_sign_in_at – timestamptz (nullable)
created_at – timestamptz (nullable)
updated_at – timestamptz (nullable)
email – generated text from identity_data->>'email' (nullable)
id – uuid PK (not null)
sessions

id – uuid PK (not null)
user_id – uuid (not null)
created_at – timestamptz (nullable)
updated_at – timestamptz (nullable)
factor_id – uuid (nullable)
aal – aal_level (nullable)
not_after – timestamptz (nullable)
refreshed_at – timestamp (nullable)
user_agent – text (nullable)
ip – inet (nullable)
tag – text (nullable)
mfa_factors

id – uuid PK (not null)
user_id – uuid (not null)
friendly_name – text (nullable)
factor_type – factor_type not null (totp, webauthn, phone)
status – factor_status not null (unverified, verified)
created_at – timestamptz (not null)
updated_at – timestamptz (not null)
secret – text (nullable)
phone – text (nullable)
last_challenged_at – timestamptz (nullable)
web_authn_credential – jsonb (nullable)
web_authn_aaguid – uuid (nullable)
mfa_challenges

id – uuid PK (not null)
factor_id – uuid (not null)
created_at – timestamptz (not null)
verified_at – timestamptz (nullable)
ip_address – inet (not null)
otp_code – text (nullable)
web_authn_session_data – jsonb (nullable)
mfa_amr_claims

session_id – uuid PK (not null)
created_at – timestamptz (not null)
updated_at – timestamptz (not null)
authentication_method – text (not null)
id – uuid PK (not null)
sso_providers

id – uuid PK (not null)
resource_id – text (nullable, non‑empty)
created_at – timestamptz (nullable)
updated_at – timestamptz (nullable)
disabled – boolean (nullable)
sso_domains

id – uuid PK (not null)
sso_provider_id – uuid (not null)
domain – text not null, non‑empty
created_at – timestamptz (nullable)
updated_at – timestamptz (nullable)
saml_providers

id – uuid PK (not null)
sso_provider_id – uuid (not null)
entity_id – text not null, non‑empty, unique
metadata_xml – text not null, non‑empty
metadata_url – text (nullable, non‑empty)
attribute_mapping – jsonb (nullable)
created_at – timestamptz (nullable)
updated_at – timestamptz (nullable)
name_id_format – text (nullable)
saml_relay_states

id – uuid PK (not null)
sso_provider_id – uuid (not null)
request_id – text not null, non‑empty
for_email – text (nullable)
redirect_to – text (nullable)
created_at – timestamptz (nullable)
updated_at – timestamptz (nullable)
flow_state_id – uuid (nullable)
flow_state

id – uuid PK (not null)
user_id – uuid (nullable)
auth_code – text (not null)
code_challenge_method – code_challenge_method not null (s256, plain)
code_challenge – text (not null)
provider_type – text (nullable)
provider_access_token – text (nullable)
provider_refresh_token – text (nullable)
created_at – timestamptz (nullable)
updated_at – timestamptz (nullable)
authentication_method – text (not null)
auth_code_issued_at – timestamptz (nullable)
one_time_tokens

id – uuid PK (not null)
user_id – uuid (not null)
token_type – one_time_token_type not null (confirmation_token, reauthentication_token, recovery_token, email_change_token_new, email_change_token_current, phone_change_token)
token_hash – text not null, non‑empty
relates_to – text (not null)
created_at – timestamp not null, default now()
updated_at – timestamp not null, default now()
Relationships (FKs)

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
2. public schema
Core user‑related tables
profiles

id – uuid PK, FK → auth.users.id (not null)
email – text unique, not null
first_name – text (nullable)
last_name – text (nullable)
phone – text (nullable)
avatar_url – text (nullable)
position – text (nullable)
is_active – boolean default true (nullable)
created_at – timestamptz default now() (nullable)
updated_at – timestamptz default now() (nullable)
permissions

id – uuid PK (not null)
user_id – uuid (nullable) → public.profiles.id
module – text (not null)
action – text (not null)
granted_by – uuid (nullable) → public.profiles.id
created_at – timestamptz default now() (nullable)
user_roles

id – uuid PK (not null)
user_id – uuid (not null) → auth.users.id
role – app_role not null (owner, manager, employee)
created_at – timestamptz default now() (nullable)
Business entities
companies

id – uuid PK (not null)
name – text (not null)
description – text (nullable)
logo_url – text (nullable)
address – text (nullable)
phone – text (nullable)
email – text (nullable)
tax_number – text (nullable)
currency – text default 'FCFA' (nullable)
timezone – text default 'Africa/Douala' (nullable)
default_tax_rate – numeric default 19.25 (nullable)
fiscal_year_start – date default '2024-01-01' (nullable)
subscription_plan – text default 'standard' (nullable)
subscription_status – text default 'active' (nullable)
subscription_expires_at – timestamptz (nullable)
settings – jsonb default '{}' (nullable)
is_active – boolean default true (nullable)
created_by – uuid (nullable) → public.profiles.id
created_at – timestamptz default now() (nullable)
updated_at – timestamptz default now() (nullable)
banner_url – text (nullable)
company_members

id – uuid PK (not null)
company_id – uuid (not null) → public.companies.id
user_id – uuid (not null) → auth.users.id
role – app_role default 'employee' (not null) (owner,manager,employee)
permissions – jsonb default '{}' (nullable)
is_active – boolean default true (nullable)
joined_at – timestamptz default now() (nullable)
invited_by – uuid (nullable)
categories

id – uuid PK (not null)
name – text (not null)
description – text (nullable)
parent_id – uuid (nullable) → public.categories.id
image_url –