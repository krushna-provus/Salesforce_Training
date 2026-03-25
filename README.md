# Custom Salesforce CPQ: Apex Refactor Project

This project contains a Custom CPQ (Configure, Price, Quote) solution for Salesforce. Originally built using declarative Record-Triggered Flows, this system has been refactored into Apex to provide better performance, advanced error handling, and full test coverage.

---

## 🚀 Project Overview

The goal of this project is to automate the sales cycle—from product creation and pricing to intelligent discounting and manager approvals. By moving the logic to Apex, the system follows the Service/Handler Pattern, ensuring the code is bulkified, maintainable, and decoupled from the trigger context.

---

## 🛠 Features & Logic

### 1. Automated Pricebook Entry (Product Automation)

Manually adding products to multiple pricebooks is time-consuming and prone to error. This trigger automates the creation of PricebookEntries.

**Logic:** When a Product is created with the **List Price** and **Targeted Pricebook** fields populated, the trigger automatically:
- Creates a Standard Pricebook Entry.
- Creates a Custom Pricebook Entry for the specified Targeted Pricebook.

**Technical Components:**
| File | Type |
|------|------|
| `ProductTrigger.trigger` | After Insert Trigger |
| `ProductService.cls` | Service Class |
| `ProductServiceTest.cls` | Test Class |

---

### 2. Automated Quote Submission (Approval Automation)

To ensure high-discount quotes are reviewed, this trigger handles the programmatic submission to the Salesforce Approval Engine.

**Logic:** When the `Is_Approval_Required__c` checkbox is updated to `true`, the trigger invokes the **"Manager Approval"** process. This sends an immediate notification to the assigned Manager.

**Technical Components:**
| File | Type |
|------|------|
| `QuoteApprovalTrigger.trigger` | After Update Trigger |
| `QuoteApprovalHandler.cls` | Handler Class |
| `QuoteApprovalHandlerTest.cls` | Test Class |

---

### 3. Intelligent Discounting (Quote Line Item Logic)

This is the core "brain" of the CPQ system, managing two distinct discounting scenarios based on the Product Category thresholds.

#### 3.1 Default Discounting

**Logic:** If the **Auto-Apply Discount** field is checked on a Line Item, the trigger retrieves the **Default Discount** from the associated `Product_Category__c` and applies it automatically.

#### 3.2 Threshold & Approval Flagging

**Logic:** Evaluates the manual discount entered by the Sales Rep:

| Scenario | Condition | Action |
|----------|-----------|--------|
| Within Threshold | Discount ≤ Threshold Discount | No action required |
| Exceeds Threshold | Discount > Threshold but ≤ Max Allowable Discount | Flags parent Quote as `Is_Approval_Required = true` |

**Technical Components:**
| File | Type |
|------|------|
| `QuoteLineItemTrigger.trigger` | Before Insert, After Insert, After Update Trigger |
| `QuoteLineItemAutomatedDiscount.cls` | Handler Class (contains both methods) |
| `QuoteBusinessLogicTest.cls` | Consolidated Test Class |

---

## 🏗 Architectural Principles

- **Bulkification:** All triggers are designed to handle up to 200 records per transaction without hitting Governor Limits.
- **One Trigger Per Object:** Follows the best practice of having a single trigger per object that delegates logic to handler classes.
- **`@testSetup`:** Uses centralized test data creation to ensure fast and efficient unit testing.
- **Security:** Classes utilize the `with sharing` keyword to respect Salesforce data security models.
