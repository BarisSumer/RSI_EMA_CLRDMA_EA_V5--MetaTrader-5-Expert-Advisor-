# 📈 RSI_EMA_CLRDMA_EA_V5 (MetaTrader 5 Expert Advisor)

![Platform](https://img.shields.io/badge/Platform-MetaTrader%205-green)
![Language](https://img.shields.io/badge/Language-MQL5-blue)
![Version](https://img.shields.io/badge/Version-5.0-orange)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

**RSI_EMA_CLRDMA_EA_V5** is an advanced algorithmic trading robot developed for MetaTrader 5. It utilizes a multi-indicator strategy combining **EMA crossovers**, **CLRDMA momentum analysis**, and **Price Action patterns** (Flat Top/Bottom) to identify high-probability trend entries.

Unlike simple trading bots, this system prioritizes capital preservation through **Dynamic Risk Management** mechanisms, including ZigZag-based Stop Losses and daily drawdown limits.

## 🚀 Key Features

* **Trend Following:** Identifies the primary market direction using Fast and Slow Exponential Moving Averages (EMA).
* **Momentum Confirmation:** Uses **CLRDMA** (Customized Linear Relative Difference of Moving Averages) to validate trend strength and filter out weak moves.
* **Noise Filtering:** Incorporates `Flat Top` and `Flat Bottom` detection algorithms to avoid entering trades during consolidation/ranging markets.
* [cite_start]**Dynamic Stop Loss:** Instead of static pip values, it leverages the **ZigZag** indicator to place Stop Loss orders at recent Support/Resistance levels[cite: 85, 89].
* **Risk Management:**
    * [cite_start]**Daily Limits:** Automatically stops trading if the daily loss limit (`MaxDailyLoss`) or maximum trade count (`MaxTradesPerDay`) is reached[cite: 71, 145, 146].
    * [cite_start]**R:R Ratio:** Calculates Take Profit dynamically based on a user-defined Risk-to-Reward ratio[cite: 76, 144].

## 🧠 Trading Strategy

The EA analyzes the market on every tick and executes trades based on the following logic:

### 🟢 Buy (Long) Signal
1.  [cite_start]**Trend:** Fast EMA (8) is **above** Slow EMA (21)[cite: 47, 197].
2.  [cite_start]**Momentum:** CLRDMA value is **positive** (> 0)[cite: 194].
3.  [cite_start]**Pattern:** A `Flat Bottom` formation is detected in the last 3 bars[cite: 195].

### 🔴 Sell (Short) Signal
1.  [cite_start]**Trend:** Fast EMA (8) is **below** Slow EMA (21)[cite: 189].
2.  [cite_start]**Momentum:** CLRDMA value is **negative** (< 0)[cite: 186].
3.  [cite_start]**Pattern:** A `Flat Top` formation is detected in the last 3 bars[cite: 187].

### 🛡️ Exit Strategy
* [cite_start]**Stop Loss (SL):** Placed at the most recent ZigZag High/Low if `UseZigZagSL` is enabled[cite: 89].
* [cite_start]**Take Profit (TP):** Calculated as `SL Distance * RiskRewardRatio` (e.g., 2.0)[cite: 76].

## 🛠️ Installation

1.  **Download:** Clone this repository or download the `.mq5` file.
2.  **Locate Folder:** Open MetaTrader 5 and go to **File > Open Data Folder**.
3.  **Install EA:** Place `RSI_EMA_CLRDMA_EA_V5.mq5` into `MQL5\Experts\`.
4.  [cite_start]**Dependencies:** Ensure the standard **ZigZag** indicator is present in `MQL5\Indicators\Examples\ZigZag.ex5` (Required for dynamic SL)[cite: 148].
5.  **Compile:** Open the file in MetaEditor (F4) and click **Compile** (F7).
6.  [cite_start]**Run:** Drag the EA onto a chart (Recommended: USDJPY M15)[cite: 117].

## ⚙️ Input Parameters

| Parameter | Default | Description |
| :--- | :--- | :--- |
| **rsiPeriod** | 14 | [cite_start]Period for RSI indicator (Monitoring) [cite: 133] |
| **emaFastPeriod** | 8 | [cite_start]Period for Fast EMA (Trend) [cite: 134] |
| **emaSlowPeriod** | 21 | [cite_start]Period for Slow EMA (Trend) [cite: 135] |
| **UseCLRDMA** | true | [cite_start]Enable/Disable CLRDMA filter [cite: 137] |
| **clrFastPeriod** | 5 | [cite_start]Fast period for CLRDMA calculation [cite: 138] |
| **clrSlowPeriod** | 20 | [cite_start]Slow period for CLRDMA calculation [cite: 139] |
| **LotSize** | 0.1 | [cite_start]Fixed lot size per trade [cite: 141] |
| **RiskRewardRatio** | 2.0 | [cite_start]Target R:R ratio for TP calculation [cite: 144] |
| **UseZigZagSL** | true | [cite_start]Use ZigZag levels for dynamic Stop Loss [cite: 142] |
| **MaxTradesPerDay** | 5 | [cite_start]Maximum allowed trades per day [cite: 145] |
| **MaxDailyLoss** | 100.0 | [cite_start]Maximum daily loss limit ($) [cite: 146] |

## 📊 Backtest Results

* **Symbol:** USDJPY
* **Timeframe:** M15
* **Observation:** The strategy effectively filtered out sideways market noise using the Flat Top/Bottom logic. [cite_start]The daily risk limits successfully prevented overtrading during volatile sessions[cite: 242].

## ⚠️ Disclaimer

Trading Forex and CFDs carries a high level of risk and may not be suitable for all investors. This Expert Advisor is provided for educational and research purposes only. Please test thoroughly on a demo account before using real funds.

---
**Developer:** [Your Name/Username]
