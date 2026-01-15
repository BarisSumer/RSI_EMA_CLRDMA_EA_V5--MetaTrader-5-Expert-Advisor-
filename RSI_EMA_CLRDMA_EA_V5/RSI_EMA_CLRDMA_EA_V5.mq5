//+------------------------------------------------------------------+
//|                RSI_EMA_CLRDMA_EA_V5.mq5                          |
//|  Aşama 5: Test, input paneli ve final düzenlemeler              |
//+------------------------------------------------------------------+
#property copyright "BarisSumer"
#property version   "5.00"
#property strict

#include <Trade\Trade.mqh>
CTrade trade;

//-----------------------------
// Kullanıcı Input Paneli
//-----------------------------
input int    rsiPeriod       = 14;
input int    emaFastPeriod   = 8;
input int    emaSlowPeriod   = 21;
input int    cmfPeriod       = 20;

input bool   UseCLRDMA       = true;
input int    clrFastPeriod   = 5;
input int    clrSlowPeriod   = 20;
input ENUM_MA_METHOD clrMethod = MODE_EMA;

input double LotSize         = 0.1;
input int    StopLoss        = 30;
input int    TakeProfit      = 60;
input double RiskRewardRatio = 2.0;

input bool   UseZigZagSL     = true;
input bool   UseStaticSLTP   = true;
input bool   EnableLogging   = true;
input int    MaxTradesPerDay = 5;
input double MaxDailyLoss    = 100.0;

input int    Slippage        = 10;
input int    MagicNumber     = 123456;

//-----------------------------
int dailyTradeCount = 0;
double dailyLossAmount = 0.0;
datetime lastTradeDate = 0;
int zigzagHandle;

//+------------------------------------------------------------------+
//| CLRDMA                                                           |
//+------------------------------------------------------------------+
double GetCLRDMA(string symbol, ENUM_TIMEFRAMES tf, int shift = 0)
{
   int fastHandle = iMA(symbol, tf, clrFastPeriod, 0, clrMethod, PRICE_CLOSE);
   int slowHandle = iMA(symbol, tf, clrSlowPeriod, 0, clrMethod, PRICE_CLOSE);
   double fastBuffer[], slowBuffer[];

   if (CopyBuffer(fastHandle, 0, shift, 1, fastBuffer) < 0 ||
       CopyBuffer(slowHandle, 0, shift, 1, slowBuffer) < 0) return 0;

   return (fastBuffer[0] - slowBuffer[0]);
}

//+------------------------------------------------------------------+
//| ZigZag destek/direnç                                            |
//+------------------------------------------------------------------+
double GetRecentZigZagLevel(bool isBuy)
{
   double zzBuffer[];
   if (CopyBuffer(zigzagHandle, 0, 0, 100, zzBuffer) <= 0) return 0;

   for (int i = 1; i < ArraySize(zzBuffer); i++)
   {
      if (MathAbs(zzBuffer[i]) > 0.00001)  // ZigZag sıfır değilse
         return zzBuffer[i];
   }
   return 0;
}

//+------------------------------------------------------------------+
//| Flat Top/Bottom Algıları                                        |
//+------------------------------------------------------------------+
bool IsFlatTop(string symbol, ENUM_TIMEFRAMES tf, int bars = 3)
{
   double highs[];
   if (CopyHigh(symbol, tf, 0, bars, highs) < bars) return false;
   for (int i = 1; i < bars; i++)
      if (NormalizeDouble(highs[i], _Digits) != NormalizeDouble(highs[0], _Digits)) return false;
   return true;
}

bool IsFlatBottom(string symbol, ENUM_TIMEFRAMES tf, int bars = 3)
{
   double lows[];
   if (CopyLow(symbol, tf, 0, bars, lows) < bars) return false;
   for (int i = 1; i < bars; i++)
      if (NormalizeDouble(lows[i], _Digits) != NormalizeDouble(lows[0], _Digits)) return false;
   return true;
}

//+------------------------------------------------------------------+
//| Pozisyon Açma                                                   |
//+------------------------------------------------------------------+
void OpenPosition(string type)
{
   double price = (type == "buy") ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double tp_pips = (RiskRewardRatio > 0.1) ? (StopLoss * RiskRewardRatio * _Point) : TakeProfit * _Point;
   double sl = 0;
   double tp = (type == "buy") ? price + tp_pips : price - tp_pips;

   if (UseZigZagSL)
      sl = (type == "buy") ? GetRecentZigZagLevel(false) : GetRecentZigZagLevel(true);
   else if (UseStaticSLTP)
      sl = (type == "buy") ? price - StopLoss * _Point : price + StopLoss * _Point;

   MqlTradeRequest request;
   MqlTradeResult result;
   ZeroMemory(request);
   ZeroMemory(result);

   request.action   = TRADE_ACTION_DEAL;
   request.symbol   = _Symbol;
   request.volume   = LotSize;
   request.type     = (type == "buy") ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   request.price    = price;
   request.sl       = sl;
   request.tp       = tp;
   request.deviation= Slippage;
   request.magic    = MagicNumber;
   request.comment  = type;
   request.type_filling = ORDER_FILLING_RETURN;

   if (OrderSend(request, result))
   {
      if (EnableLogging)
         Print("✅ ", type, " emri gönderildi | SL: ", DoubleToString(sl, _Digits), " | TP: ", DoubleToString(tp, _Digits));
      dailyTradeCount++;
      lastTradeDate = TimeCurrent();
   }
   else
   {
      if (EnableLogging)
         Print("❌ Emir başarısız: ", result.retcode);
   }
}

//+------------------------------------------------------------------+
//| Main Tick                                                       |
//+------------------------------------------------------------------+
void OnTick()
{
   MqlDateTime nowStruct, lastStruct;
   TimeToStruct(TimeCurrent(), nowStruct);
   TimeToStruct(lastTradeDate, lastStruct);

   if (nowStruct.day != lastStruct.day)
   {
      dailyTradeCount = 0;
      dailyLossAmount = 0.0;
   }

   if (dailyTradeCount >= MaxTradesPerDay || dailyLossAmount >= MaxDailyLoss)
   {
      if (EnableLogging)
         Print("🛑 Günlük işlem veya kayıp limiti aşıldı.");
      return;
   }

   static datetime lastBarTime = 0;
   datetime currentBarTime = iTime(_Symbol, _Period, 0);
   if (currentBarTime == lastBarTime) return;
   lastBarTime = currentBarTime;

   double rsi = iRSI(_Symbol, _Period, rsiPeriod, PRICE_CLOSE);
   double emaFast = iMA(_Symbol, _Period, emaFastPeriod, 0, MODE_EMA, PRICE_CLOSE);
   double emaSlow = iMA(_Symbol, _Period, emaSlowPeriod, 0, MODE_EMA, PRICE_CLOSE);
   double clr = GetCLRDMA(_Symbol, _Period, 0);

   bool flatTop = IsFlatTop(_Symbol, _Period, 3);
   bool flatBottom = IsFlatBottom(_Symbol, _Period, 3);

   if (EnableLogging)
      Print("📊 RSI=", rsi, " | EMAFast=", emaFast, " | EMASlow=", emaSlow, " | CLRDMA=", clr);

   if (!PositionSelect(_Symbol))
   {
      if (emaFast > emaSlow && clr > 0 && flatBottom)
         OpenPosition("buy");
      else if (emaFast < emaSlow && clr < 0 && flatTop)
         OpenPosition("sell");
   }
}

//+------------------------------------------------------------------+
//| Initialization                                                  |
//+------------------------------------------------------------------+
int OnInit()
{
   zigzagHandle = iCustom(_Symbol, _Period, "Examples\\ZigZag", 12, 5, 3);
   if (zigzagHandle == INVALID_HANDLE)
   {
      Print("❌ ZigZag göstergesi yüklenemedi.");
      return INIT_FAILED;
   }
   Print("✅ EA başlatıldı - RSI_EMA_CLRDMA_EA_V5");
   return INIT_SUCCEEDED;
}
