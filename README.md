# Salesforce Travel Gift Certificate Generator

## 📌 Overview
This repository contains a complete Salesforce solution for generating dynamic, A5 Landscape PDF vouchers from the `Credit_Memo__c` object. The solution is highly configurable, adhering to Salesforce best practices (Clicks-not-Code where possible, bulkified Apex, strict security enforcement).

## 🏗 Architecture & Key Features

### 1. Data Model & Configuration
* **Credit Memo (`Credit_Memo__c`)**: The core transaction object, linked to `Account` via a Master-Detail relationship.
* **Default Notes Automation**: Default Terms & Conditions are stored securely in a **Custom Metadata Type** (`Voucher_Setting__mdt`). A **Before-Save Record-Triggered Flow** dynamically injects the `Credit_Expiry_Date__c` into the template upon record creation and populates the Rich Text `Notes__c` field.

### 2. Dynamic Background Image Logic (Developer Suggestion)
Instead of hardcoding images in Static Resources, the solution uses a flexible, database-driven approach utilizing standard **Salesforce Files** (`ContentVersion` / `ContentDocumentLink`):
* **Global Images**: Admins can upload default backgrounds to the `Voucher_Background__c` object and define `Expiry_From_Date__c` and `Expiry_To_Date__c`.
* **Override Images**: Users can upload a custom image directly to the specific `Credit_Memo__c` record.
* **Resolution Logic**: The Apex service (`VoucherService`) first checks for an override image on the Memo. If none exists, it falls back to the active Global Image matching the expiry date criteria.

### 3. User Interface & PDF Generation
* **Live Preview (LWC)**: A custom Lightning Web Component (`voucherImagePreview`) is available on the Lightning Record Page, allowing users to preview the exact background image (Global or Override) that will be printed.
* **PDF Engine**: A lightweight Visualforce Page (`VoucherPDF`) rendered as PDF. It utilizes strict CSS `@page` rules to enforce exact A5 Landscape dimensions (157.5mm x 111mm) and absolute positioning, resolving common Flying Saucer rendering bugs (such as blank pages and repeating fixed elements).
* **Print Action**: A Custom Button configured to safely bypass Lightning Navigation quirks and open the PDF reliably in a new tab (`target="_blank"`).

## 🛡 Security & Best Practices
* All SOQL queries in Apex utilize `WITH USER_MODE` to strictly enforce Object and Field-Level Security (FLS).
* Hardcoded strings for LWC error handling and UI messages are moved to **Custom Labels** to support future localization and easier maintenance.

## 🧪 Testing
The solution includes comprehensive Apex Test coverage (>95%):
* `VoucherServiceTest`: Utilizes `@TestSetup` to mock complex `ContentVersion` insertions and tests Global fallback vs. Override image scenarios. Uses the modern `Assert` class.
* `VoucherPDFControllerTest`: Ensures standard controller initialization and null-handling.
