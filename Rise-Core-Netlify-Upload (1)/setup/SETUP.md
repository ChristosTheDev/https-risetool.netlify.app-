# Rise Content — setup and current release

Updated 2026-09-12. This release starts with a query, a URL, or pasted content.

## What works in this release

| Starting point | Implemented behavior |
|---|---|
| Target a query | Enter query, location, country, language and device. After server setup, fetch a live Organic SERP, show distinct organic URLs and store the original response. |
| Start with a URL | After server setup, retrieve reported organic keywords for the exact HTTPS URL from DataForSEO Labs. Select a keyword to fill the target-query form. Results and volume are country-level database observations, not a fresh local rank check. |
| Paste your content | Find literal candidate phrases in English text without an API request. Choose a candidate to fill the target-query form. These are not measured rankings or search volumes. |
| Saved lookups | Sign in to reopen your saved provider results without another paid provider request. |
| Connections | Sign in with a Supabase user, test database write/read and DataForSEO API credentials, and see missing variables. |

Full page extraction, NLP competitor analysis, automatic IMPROVE/REWRITE decisions, briefs and Claude drafts are still not connected. Their values remain MISSING. The prior synthetic report is available separately as Example report. It is not populated from your query.

## Deploy the source project

Use **Rise-Core-With-Dashboard-Source.zip** for this step. Uploading only the compiled website through Netlify's dropzone does not install the supplied server function.

1. Extract the source ZIP. Its root contains `web`, `supabase`, `engine`, `kb`, and `README.md`.
2. Create a private GitHub repository. Upload those folders and files into the repository root, then commit. Do not upload the ZIP itself as one repository file.
3. In your existing Netlify project, connect this repository for continuous deployment. Keep using the same Netlify project to preserve its URL.
4. Use **Base directory: `web`**, **Build command: `npm run build`**, **Publish directory: `dist`**. The included `web/netlify.toml` sets the Functions directory to `netlify/functions` relative to the base.
5. Add the required environment variables below, then deploy the project.
6. Check that Netlify lists a function named **gateway**. Open the website and select **Connections → Check server deployment**.

The compiled frontend is also included at `web/dist/` for inspection. No API credentials are needed just to open it and use the local pasted-content candidate check. Live discovery needs the deployed function and the database setup.

## Prepare Supabase

1. In your Supabase project, open **SQL Editor → New query**.
2. Paste and run `supabase/002_discovery.sql`, also provided as **Rise-Core-Supabase-Setup.sql**. This creates the discovery tables and owner-only read policies. It does not require the earlier design-only core schema and does not delete existing data.
3. Under **Authentication → Users**, create your agency user with an email and password and confirm the user. This is the user you sign in with inside Rise Content; it is separate from your Supabase dashboard account.
4. Under the project's **Connect** dialog / **Settings → API Keys**, obtain the project URL, publishable key and secret key.

## Required Netlify variables

Open **Project configuration → Environment variables**. Set these for the production deploy. Where scope selection is available, include **Functions**. Redeploy after adding or changing values.

| Variable | Value to enter |
|---|---|
| `SUPABASE_URL` | Supabase project origin, such as `https://YOUR_PROJECT.supabase.co` |
| `SUPABASE_PUBLISHABLE_KEY` | Project publishable key, beginning `sb_publishable_` |
| `SUPABASE_SECRET_KEY` | Project secret key, beginning `sb_secret_` |
| `AGENCY_ALLOWED_EMAILS` | Exact email of the user created under Supabase Authentication. Separate additional permitted emails with commas. |
| `DATAFORSEO_LOGIN` | Login shown in DataForSEO **API access** |
| `DATAFORSEO_PASSWORD` | Password shown in DataForSEO **API access**, which may differ from your account password |

Existing legacy variables `SUPABASE_ANON_KEY` and `SUPABASE_SERVICE_ROLE_KEY` are accepted as alternatives. Prefer the publishable/secret keys for a new setup. Do not put secret values in website files, GitHub commits, frontend code or VITE-prefixed variables. This build reads them only in the server function.

You do not need a Google OAuth client ID or client secret for these DataForSEO lookups. No VITE-prefixed variables or SITE_URL variable are required by this release.

## Later analysis and writing variables

These enable connection diagnostics only at present. Adding them does not activate the unfinished full analysis pipeline.

| Variable | Purpose |
|---|---|
| `ANALYSIS_API_URL` | HTTPS origin of the future Render analysis web service |
| `ANALYSIS_API_TOKEN` | Shared secret accepted by that service |
| `ANTHROPIC_API_KEY` | Claude API key, from Claude Console |
| `TEXT_GENERATOR_MODEL` | Exact model ID or supported alias available to that API account |

The Render host and background worker remain the approved deployment target. Its ASGI runner still needs approval under the original instruction to ask before adding an unlisted dependency; Uvicorn has not been installed. The writer provider adapter remains configurable in the core. This release's diagnostic check is specifically for Claude's Models API and does not generate text.

## Verify the setup

1. Open **Connections** in the deployed dashboard and sign in with the Supabase user you created.
2. Run **Test connections**. Supabase should report a successful authenticated server-side database write/read. DataForSEO should report a successful free API credential check.
3. Start one target-query lookup using your real location. The estimated provider cost appears before you submit. After it returns, check the location, organic URLs, saved raw response and provider-reported cost.
4. Open **Saved lookups** and reopen the result. This should read storage without another DataForSEO request.
5. Test **Start with a URL** using an exact published HTTPS page URL. Missing provider records are not proof that the page never ranks. Pagination is explicit and each next-page request shows its estimate.

Connection checks do not prove paid-endpoint coverage, sufficient provider balance, the complete unfinished pipeline, or future uptime. A successful real lookup and saved-response read are required to verify your own deployment. No live credentials or paid requests were used in the development tests.

## Troubleshooting

| Message | Action |
|---|---|
| Server function is not deployed | Deploy the source project with its function; confirm `gateway` appears in Netlify. |
| Supabase storage check failed | Run the supplied discovery SQL in the same project as your configured keys; check the server secret key. |
| User not included in AGENCY_ALLOWED_EMAILS | Add the user's exact email to that variable and redeploy. |
| Sign-in failed | Check the Authentication user, password and email confirmation. |
| DataForSEO credential check failed | Use credentials from API access and redeploy. |
| Location not found | Use Find location, choose a returned location and check the country code. |
| Unknown outcome / raw storage failure | Inspect Saved lookups before retrying. The original request may have incurred a cost; the app does not retry it automatically. |

## Verified documentation

Checked 2026-09-12; vendor documentation, T2. Product behavior above is the implementation scope, not an SEO ranking claim.

- Netlify function deployment: https://docs.netlify.com/build/functions/get-started/
- Netlify variables and redeployment: https://docs.netlify.com/build/functions/environment-variables/
- Supabase API key handling: https://supabase.com/docs/guides/getting-started/api-keys
- DataForSEO exact URL keyword lookup: https://docs.dataforseo.com/v3/dataforseo_labs-google-ranked_keywords-live/
- DataForSEO free credential/account endpoint: https://docs.dataforseo.com/v3/appendix-user-data/
- Claude model access check: https://platform.claude.com/docs/en/api/models/retrieve

Module 0 and KB-12 remain parked and unchanged.
