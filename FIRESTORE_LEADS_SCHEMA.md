# Firestore Schema for SME Radar Leads

This document defines the first version of the Firestore data model for the B2B Opportunities Dashboard.

## 1) Collection: onhold_users

Document ID: user uid

Purpose: SME profile used for targeting and lead scoring.

Core fields:

- `firstName` (string)
- `lastName` (string)
- `website` (string)
- `productCategory` (string)
- `marketCountry` (string)
- `seasonalCalendar` (string)
- `naceCode` (string)
- `profileStage` (string, example: `completed_profile`)
- `lastSeenAt` (timestamp)

Existing compatibility fields kept:

- `market`, `forecastHorizonDays`, and existing auth/state fields.

## 2) Collection: leads

Document ID: auto-id or deterministic id from source + afm

Purpose: Potential customer lead records coming from GEMI CSV/API and gov.data.gr datasets.

Fields:

- `ownerUid` (string) - user that sees this lead
- `source` (string) - `businessportal.gr`, `gov.data.gr`, `elstat`, etc.
- `companyName` (string)
- `website` (string)
- `afm` (string)
- `legalForm` (string)
- `hqAddress` (string)
- `city` (string)
- `naceCode` (string)
- `secondaryNaceCodes` (array of strings)
- `scoreValue` (number, 0.0 - 1.0)
- `scoreBand` (string enum: `HIGH`, `MEDIUM`, `LOW`)
- `fitReason` (string)
- `status` (string enum: `new`, `contacted`, `qualified`, `won`, `lost`)
- `radarRunId` (string)
- `createdAt` (timestamp)
- `updatedAt` (timestamp)

## 3) Collection: radar_runs

Document ID: run id

Purpose: Track each data ingestion and scoring cycle.

Fields:

- `ownerUid` (string)
- `runType` (string enum: `scheduled`, `manual`, `backfill`)
- `sourceTypes` (array of strings)
- `recordsFetched` (number)
- `recordsScored` (number)
- `highCount` (number)
- `mediumCount` (number)
- `lowCount` (number)
- `status` (string enum: `running`, `completed`, `failed`)
- `errorMessage` (string, optional)
- `startedAt` (timestamp)
- `finishedAt` (timestamp)

## 4) Collection: notifications

Document ID: auto-id

Purpose: Email and in-app alerts for new opportunities.

Fields:

- `ownerUid` (string)
- `leadId` (string)
- `channel` (string enum: `email`, `in_app`)
- `template` (string)
- `deliveryStatus` (string enum: `queued`, `sent`, `failed`)
- `sentAt` (timestamp)
- `createdAt` (timestamp)

## 5) Suggested Indexes

Create composite indexes in Firestore:

- `leads`: ownerUid ASC, scoreValue DESC
- `leads`: ownerUid ASC, scoreBand ASC, updatedAt DESC
- `leads`: ownerUid ASC, naceCode ASC, scoreValue DESC
- `notifications`: ownerUid ASC, createdAt DESC

## 6) Cloud Functions Flow (target architecture)

1. Fetch from `gov.data.gr` API and/or ingest GEMI CSV.
2. Normalize records and map activity to NACE/KAD.
3. Score in Firebase Cloud Functions based on profile fit.
4. Write to `leads` and `radar_runs`.
5. Trigger email/in-app notification when new `HIGH` lead appears.

## 7) Scoring Output Contract

Each scored lead should return:

- `scoreValue`: decimal score
- `scoreBand`: HIGH/MEDIUM/LOW
- `fitReason`: human-readable explanation
