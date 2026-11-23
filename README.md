# A/B Test Analysis: Balancing Scam Warning Prompts vs. Checkout Friction

## Executive Summary
To reduce Authorized Push Payment (APP) fraud on instant transfers, the product team tested a behavioral warning prompt (*"Stop: Could this transfer be a scam?"*) across **20,000 user transfers**. 

* **Recommendation:** **Ship the warning screen** to production, followed by targeted UX refinement for trusted repeat payees.
* **Primary Impact (Fraud Reduction):** Completed scam transfers dropped by **1.56 percentage points** (from **4.21%** to **2.64%**, p < 0.001).
* **Guardrail Impact (Checkout Friction):** Legitimate transfer abandonment increased by **1.35 percentage points** (from **2.77%** to **4.12%**, p < 0.001).
* **Net Financial ROI:** Prevented **\$108,752.15** in fraud reimbursement losses against **\$1,350.59** in lost transaction fees—delivering a **net financial benefit of +\$107,401.57** over the test window.



[View Executive Summary](visuals/executive-summary.png)

---

## 1. Business Problem & Hypothesis
Instant payment networks expose banks to heavy reimbursement liability when customers are socially engineered into authorizing fraudulent transfers. While an interstitial warning screen can interrupt scam victims before funds leave their account, adding friction to checkout risks deterring legitimate customers and sacrificing transaction fee revenue (1.5% per transfer).

* **Hypothesis 1 (Primary Metric):** Adding a behavioral warning prompt significantly reduces the completion rate of scam transfers (\(H_1: p_{\text{control}} > p_{\text{treatment}}\)).
* **Hypothesis 2 (Guardrail Metric):** Adding a behavioral warning prompt increases the abandonment rate of legitimate transfers (\(H_1: p_{\text{treatment}} \neq p_{\text{control}}\)).

---

## 2. Data Architecture & Workflow
This project mirrors an end-to-end product analytics workflow across SQL and Python:

1. **SQL Data Extraction (`extract_data.sql`):** Joined three raw event tables (`experiment_assignments`, `transfer_events`, and `fraud_reports`) from a SQLite database (`fintech_ab_test.db`), applying `COALESCE` to classify unflagged transfers cleanly as non-scams (`0`).
2. **Data Validation (`ab_test_analysis.ipynb`):** Verified schema integrity, checked for duplicate user/transfer records, and confirmed a balanced ~50/50 randomization split (`10,012` Control vs. `9,988` Treatment).
3. **Statistical Testing & ROI Modeling:** Ran two-proportion z-tests (`statsmodels`) with 95% confidence intervals and evaluated net dollar impact using actual transaction amounts.

> **Production Lifecycle Note:** In a live engineering environment, the analyst's involvement begins prior to test launch with a **pre-test power analysis** on historical baseline logs to determine the minimum required sample size and test duration. This repository focuses on the post-experiment SQL extraction, hypothesis testing, and financial evaluation once the target sample has been collected.

---

## 3. Experiment Results

| Metric | Control (No Warning) | Treatment (Warning Prompt) | Absolute Difference | 95% Confidence Interval | z-statistic | p-value |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Sample Size (n)** | 10,012 | 9,988 | — | — | — | — |
| **Completed Scam Rate (Primary)** | 4.21% | 2.64% | **-1.56%** | [-2.07%, -1.06%] | 6.07 | `< 0.0001` |
| **Legitimate Abandonment (Guardrail)** | 2.77% | 4.12% | **+1.35%** | [+0.84%, +1.85%] | 5.23 | `< 0.0001` |

### Unit Economics & ROI Breakdown
* **Fraud Losses Prevented:** `\$108,752.15` (difference in total dollar value of completed scams between Control and Treatment)
* **Incremental Fee Revenue Lost:** `-\$1,350.59` (1.5% transaction fee on incremental abandoned legitimate transfers)
* **Net Experiment ROI:** **`+\$107,401.57`**

---

## 4. Product Recommendation & Next Steps
1. **Full Rollout:** Launch the scam warning prompt immediately. Although legitimate abandonment rose by 1.35 percentage points, the unit economics overwhelmingly favor intervention—saving over **\$80 in prevented fraud for every \$1 lost in transaction fees**.
2. **Next Iteration (Targeted Friction):** Conduct a follow-up segmentation test that suppresses the warning prompt for low-dollar transfers or recurring transfers to previously verified payees, capturing the same fraud savings while reducing false-positive checkout friction.

---

## Repository Structure
```text
├── data/
│   ├── fintech_ab_test.db                          # Raw SQLite database (3 event tables)
│   └── processed-transaction-dataset-from-db.csv   # Clean joined dataset exported from SQL
├── sql/
│   └── extract_data.sql                            # SQL query joining assignments, transfers & fraud reports
├── notebooks/
│   └── ab_test_analysis.ipynb                      # Exploratory checks, z-tests, CIs & ROI calculation
└── README.md
```

## Tools Used
* **SQL (SQLite):** Multi-table joins (`INNER JOIN`, `LEFT JOIN`), null handling (`COALESCE`)
* **Python:** `pandas`, `numpy`, `statsmodels` (two-proportion $z$-tests), `scipy.stats` (confidence intervals)



*Author: Emmanuel Bitrus*
