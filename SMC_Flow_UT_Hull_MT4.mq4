//+------------------------------------------------------------------+
//|                                  SMC_Flow_UT_Hull_3BR_MT4.mq4   |
//|  Pine code partial port for MT4                             |
//|  Implemented: UT..TAB+SBG + RS(+rsBRS/rsERS/ttERS/tsoRS/warRS semantics)     |
//|  Not yet: request.security_lower_tf                                        |
//+------------------------------------------------------------------+
#property copyright "Educational - test on demo"
#property version   "1.30"
#property strict
#property indicator_chart_window
#property indicator_buffers 24
#property indicator_plots   23

#property indicator_label1  "Hull HMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2

#property indicator_label2  "Hull HMA [+2]"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSilver

#property indicator_label3  "UT Trail"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrange

#property indicator_label4  "UT Buy"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrLime

#property indicator_label5  "UT Sell"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrRed

#property indicator_label6  "3BR Bull Confirm"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrBlue

#property indicator_label7  "3BR Bear Confirm"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrOrange

#property indicator_label8  "3BR Bull SR"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrDeepSkyBlue

#property indicator_label9  "3BR Bear SR"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrSandyBrown

#property indicator_label10 "RS Bull Mom"
#property indicator_type10  DRAW_ARROW
#property indicator_color10 clrMediumSeaGreen

#property indicator_label11 "RS Bear Mom"
#property indicator_type11  DRAW_ARROW
#property indicator_color11 clrTomato

#property indicator_label12 "RS Resistance"
#property indicator_type12  DRAW_LINE
#property indicator_color12 clrIndianRed
#property indicator_style12 STYLE_SOLID
#property indicator_width12 2

#property indicator_label13 "RS Support"
#property indicator_type13  DRAW_LINE
#property indicator_color13 clrSeaGreen
#property indicator_style13 STYLE_SOLID
#property indicator_width13 2

#property indicator_label14 "RS Ex Bull"
#property indicator_type14  DRAW_ARROW
#property indicator_color14 clrMediumPurple

#property indicator_label15 "RS Ex Bear"
#property indicator_type15  DRAW_ARROW
#property indicator_color15 clrDarkOrange

#property indicator_label16 "RS Ex Res"
#property indicator_type16  DRAW_LINE
#property indicator_color16 clrPlum
#property indicator_style16 STYLE_DOT
#property indicator_width16 1

#property indicator_label17 "RS Ex Sup"
#property indicator_type17  DRAW_LINE
#property indicator_color17 clrMediumPurple
#property indicator_style17 STYLE_DOT
#property indicator_width17 1

#property indicator_label18 "RS Mom Risk Lo"
#property indicator_type18  DRAW_LINE
#property indicator_color18 clrLime
#property indicator_style18 STYLE_DOT
#property indicator_width18 1

#property indicator_label19 "RS Mom Risk Hi"
#property indicator_type19  DRAW_LINE
#property indicator_color19 clrOrangeRed
#property indicator_style19 STYLE_DOT
#property indicator_width19 1

#property indicator_label20 "RS Ex Risk Hi"
#property indicator_type20  DRAW_LINE
#property indicator_color20 clrHotPink
#property indicator_style20 STYLE_DOT
#property indicator_width20 1

#property indicator_label21 "RS Ex Risk Lo"
#property indicator_type21  DRAW_LINE
#property indicator_color21 clrTurquoise
#property indicator_style21 STYLE_DOT
#property indicator_width21 1

#property indicator_label22 "RS Ex Tgt Lo"
#property indicator_type22  DRAW_LINE
#property indicator_color22 clrForestGreen
#property indicator_style22 STYLE_DASH
#property indicator_width22 1

#property indicator_label23 "RS Ex Tgt Hi"
#property indicator_type23  DRAW_LINE
#property indicator_color23 clrMaroon
#property indicator_style23 STYLE_DASH
#property indicator_width23 1

//--- UT Bot
input int    InpUT_Key           = 2;
input int    InpUT_ATRPeriod     = 6;
input bool   InpUT_UseHeikinAshi = false;
input bool   InpShowUT           = true;
input bool   InpShowUTSignals    = true;

//--- Hull
input int    InpHull_Length   = 55;
input double InpHull_Mult     = 1.0;
input bool   InpShowHull      = true;
input bool   InpShowHullBand  = true;

//--- Three Bar Reversal
input bool   InpShow3BR       = true;
input int    Inp3BR_PatternType = 0;  // 0=All,1=Normal,2=Enhanced
input int    Inp3BR_SRMode      = 0;  // 0=Level,1=Zone,2=None
input int    Inp3BR_TrendType   = 0;  // 0=None,1=MACloud,2=Supertrend,3=Donchian
input int    Inp3BR_TrendFilt   = 0;  // 0=Aligned,1=Opposite
input int    Inp3BR_MAType      = 2;  // 0=SMA,1=EMA,2=HMA,3=RMA,4=WMA,5=VWMA
input int    Inp3BR_MAFastLen   = 50;
input int    Inp3BR_MASlowLen   = 200;
input int    Inp3BR_ATRPeriod   = 10;
input double Inp3BR_Factor      = 3.0;
input int    Inp3BR_DonLen      = 13;

//--- FVG (Pine: detectFVG + static boxes, current TF only)
input bool   InpFVG_Show         = true;
input double InpFVG_ThresholdPct = 0.0;   // fixed threshold as percent (e.g. 0.5 = 0.5%)
input bool   InpFVG_AutoThreshold = false; // Pine auto: cum((H-L)/L)/barIndex
input int    InpFVG_ExtendBars   = 20;    // right extend in bars (Pine extendFVG)
input int    InpFVG_MaxZones     = 80;    // cap stored zones / objects
input string InpFVG_Prefix       = "SMCFVG_";
input color  InpFVG_BullColor    = C'9,136,129';
input color  InpFVG_BearColor    = C'242,54,69';

//--- LuxAlgo Order Blocks (Pine: pivothigh(volume)+os + mitigate + boxes)
input bool   InpOB_Show           = true;
input int    InpOB_Length         = 5;     // Volume pivot length (= left/right bars)
input int    InpOB_BullExt        = 3;     // Bullish OB zones drawn (newest first)
input int    InpOB_BearExt        = 3;
input int    InpOB_ExtendBars     = 500;   // Rectangle / line right edge in bars from time[0]
input int    InpOB_MaxZones       = 64;    // Cap per side (unshift stack)
input string InpOB_Prefix         = "SMCOB_";
input int    InpOB_Mitigation     = 0;     // 0=Wick (Pine default), 1=Close
input int    InpOB_LineStyle      = 0;     // 0=solid,1=dashed,2=dotted (avg line)
input int    InpOB_LineWidth      = 1;
input color  InpOB_BullBg         = C'8,153,129';
input color  InpOB_BullBorder     = C'8,153,129';
input color  InpOB_BullAvg        = C'149,152,161';
input color  InpOB_BearBg         = C'242,54,69';
input color  InpOB_BearBorder     = C'242,54,69';
input color  InpOB_BearAvg        = C'149,152,161';

//--- Reversal Signals (Pine demo11.js ~1370 + exhaustion mirror + mom phase mode)
input bool   InpRS_Show        = true;
input bool   InpRS_SRLevels    = true;   // Pine srLRS: momentum R/S
input int    InpRS_MomMode     = 0;      // 0=Completed (only 9), 1=Detailed (each step 1..9), 2=None
input bool   InpRS_ExhaustShow = true;   // mirror streak: close>close[4]
input int    InpRS_ExMode      = 0;      // 0=Completed, 1=Detailed, 2=None
input bool   InpRS_ExSrLevels  = false;  // exhaustion mirror R/S (not in Pine simplified block)
// Pine inputs exist without body in demo11.js — MT4 semantics below
input bool   InpRS_MomRiskLevels = false;  // rsBRS: invalidation low (bull mom) / high (bear mom), 9-bar window
input bool   InpRS_ExRiskLevels  = false;  // rsERS: invalidation high after ex-bull 9 / low after ex-bear 9
input bool   InpRS_ExTgtLevels   = false;  // ttERS: ex-bull target = 9-bar low / ex-bear target = 9-bar high
input int    InpRS_TradeSetup    = 0;      // tsoRS: 0=None,1=Momentum only,2=Exhaustion only,3=Qualified=both
input bool   InpRS_WarnFlip      = false;  // warRS: mark bars where close<close[4] flips vs prior bar
input int    InpRS_WarnMaxBars   = 400;
input int    InpRS_WarnMaxMarks  = 80;
input string InpRS_WarnPrefix    = "SMC_RSW_";

//--- Smart Money Concepts (Pine Mxwll: calculatePivots + ext/int structure)
input bool   InpSMC_Show       = true;
input bool   InpSMC_ShowInt    = true;   // Pine showInt
input bool   InpSMC_ShowExt    = true;   // Pine showExt
input int    InpSMC_IntSens    = 5;      // 3 / 5 / 8 in Pine
input int    InpSMC_ExtSens    = 25;     // 10 / 25 / 50 in Pine
input int    InpSMC_IntStru    = 0;      // 0=All, 1=BoS only, 2=CHoCH only (matches I-*)
input int    InpSMC_ExtStru    = 0;      // 0=All, 1=BoS, 2=CHoCH
input bool   InpSMC_ShowHH     = true;   // Pine showHHLH
input bool   InpSMC_ShowLL     = true;   // Pine showHLLL
input color  InpSMC_BullC      = C'20,217,144';
input color  InpSMC_BearC      = C'242,73,104';
input string InpSMC_Prefix     = "SMC_MS_";
input int    InpSMC_MaxObjects = 100;
//--- Auto Fib (Pine: calculatePivots(25) + updateMain + drawFibs, last bar)
input bool   InpSMC_ShowFibs     = true;
input int    InpSMC_FibLen       = 25;    // Pine calculatePivots for fib leg
input int    InpSMC_FibExtendBars = 45;   // horizontal line length to the right
input string InpSMC_FibPrefix    = "SMC_FIB_";
input color  InpSMC_FibLineCol   = clrSilver;
input color  InpSMC_FibTextCol   = clrDarkGray;

//--- Rolling HTF levels (Pine tfDraw when chart <= M60; else prev H4/D1 bar)
input bool   InpRoll4H          = true;
input bool   InpRoll1D          = true;
input bool   InpRoll4H_Labels   = true;
input bool   InpRoll1D_Labels   = true;
input int    InpRoll_ExtendBars = 200;
input string InpRoll_Prefix     = "SMC_RL_";
input color  InpRoll4H_HiCol    = clrAqua;
input color  InpRoll4H_LoCol    = clrAqua;
input color  InpRoll1D_HiCol    = clrDodgerBlue;
input color  InpRoll1D_LoCol   = clrDodgerBlue;

//--- NY session panel (Pine tab2: NY/Asia/London + countdown + roll vol sum)
input bool   InpSess_Show         = true;
input int    InpSess_NY_OffsetMin  = -300;   // add to GMT minute-of-day (EST=-300, EDT=-240)
input int    InpSess_XDist        = 12;
input int    InpSess_YDist        = 22;
input int    InpSess_LineH        = 16;
input string InpSess_Prefix       = "SMC_TAB_";
//--- Session tint bands (Pine bgcolor NY/Asia/London — bar time + same offset as tab)
input bool   InpSess_BgShow      = true;
input int    InpSess_BgMaxBars  = 500;
input string InpSess_BgPrefix   = "SMC_SBG_";
input color  InpSess_BgNY       = C'242,73,104';
input color  InpSess_BgAsia     = C'20,217,144';
input color  InpSess_BgLondon   = C'242,184,7';

#define FVG_MAX 256
struct fvg_rec
  {
   string   name;
   bool     bull;
   double   top;
   double   bot;
   datetime tDetect;
  };

fvg_rec G_fvgs[FVG_MAX];
int     G_fvg_n = 0;
datetime G_fvg_last_bar_time = 0;

#define OB_MAX 96
struct ob_rec
  {
   string   name_rect;
   string   name_line;
   double   top;
   double   bot;
   double   avg;
   datetime t_left;
  };

ob_rec   G_ob_bulls[OB_MAX];
int      G_ob_bull_n = 0;
ob_rec   G_ob_bears[OB_MAX];
int      G_ob_bear_n = 0;

bool     G_smc_fib_ok = false;
double   G_smc_fib_base = 0.0;
double   G_smc_fib_span = 0.0;
datetime G_smc_fib_t_left = 0;

double BufHull[];
double BufHull2[];
double BufTrail[];
double BufBuy[];
double BufSell[];
double Buf3BRBull[];
double Buf3BRBear[];
double Buf3BRBullSR[];
double Buf3BRBearSR[];
double BufRaw[];
double BufRS_Bull[];
double BufRS_Bear[];
double BufRS_Res[];
double BufRS_Sup[];
double BufRS_ExBull[];
double BufRS_ExBear[];
double BufRS_ExRes[];
double BufRS_ExSup[];
double BufRS_MomRiskLo[];
double BufRS_MomRiskHi[];
double BufRS_ExRiskHi[];
double BufRS_ExRiskLo[];
double BufRS_ExTgtLo[];
double BufRS_ExTgtHi[];

#ifndef OBJ_RECTANGLE
   #define OBJ_RECTANGLE 17
#endif

//+------------------------------------------------------------------+
datetime FvgBarSeconds()
  {
   return((datetime)Period() * 60);
  }

//+------------------------------------------------------------------+
double FvgThresholdAuto(const double &high[], const double &low[], int oldest, int i)
  {
   double cum = 0.0;
   for(int k = oldest; k >= i; k--)
     {
      double L = low[k];
      if(L <= 0.0) continue;
      cum += (high[k] - low[k]) / L;
     }
   int bars = oldest - i + 1;
   if(bars < 1) bars = 1;
   return(cum / (double)bars);
  }

//+------------------------------------------------------------------+
void FvgRemoveAt(int idx)
  {
   if(idx < 0 || idx >= G_fvg_n) return;
   ObjectDelete(0, G_fvgs[idx].name);
   for(int k = idx; k < G_fvg_n - 1; k++)
      G_fvgs[k] = G_fvgs[k + 1];
   G_fvg_n--;
  }

//+------------------------------------------------------------------+
void FvgMitigateWithClose(const double cl)
  {
   for(int j = G_fvg_n - 1; j >= 0; j--)
     {
      if(G_fvgs[j].bull && cl < G_fvgs[j].bot) FvgRemoveAt(j);
      else if(!G_fvgs[j].bull && cl > G_fvgs[j].top) FvgRemoveAt(j);
     }
  }

//+------------------------------------------------------------------+
bool FvgCreateRect(string nm, datetime tL, datetime tR, double pTop, double pBot, color c)
  {
   if(ObjectFind(0, nm) >= 0) ObjectDelete(0, nm);
   if(!ObjectCreate(0, nm, OBJ_RECTANGLE, 0, tL, pTop, tR, pBot)) return(false);
   ObjectSet(nm, OBJPROP_COLOR, c);
   ObjectSet(nm, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(nm, OBJPROP_WIDTH, 1);
   ObjectSet(nm, OBJPROP_BACK, true);
   return(true);
  }

//+------------------------------------------------------------------+
void FvgPushZone(string nm, bool bull, double top, double bot, datetime tL, datetime tR)
  {
   while(G_fvg_n >= InpFVG_MaxZones) FvgRemoveAt(0);
   G_fvgs[G_fvg_n].name = nm;
   G_fvgs[G_fvg_n].bull = bull;
   G_fvgs[G_fvg_n].top = top;
   G_fvgs[G_fvg_n].bot = bot;
   G_fvgs[G_fvg_n].tDetect = tL;
   if(FvgCreateRect(nm, tL, tR, top, bot, bull ? InpFVG_BullColor : InpFVG_BearColor))
      G_fvg_n++;
  }

//+------------------------------------------------------------------+
void FvgRebuildFull(const datetime &time[], const double &high[], const double &low[], const double &close[], int rates_total)
  {
   ObjectsDeleteAll(0, InpFVG_Prefix);
   G_fvg_n = 0;
   if(!InpFVG_Show)
     {
      G_fvg_last_bar_time = time[0];
      return;
     }
   int oldest = rates_total - 1;
   datetime sec = FvgBarSeconds();
   for(int i = oldest - 2; i >= 0; i--)
     {
      FvgMitigateWithClose(close[i]);

      double thr = InpFVG_AutoThreshold ? FvgThresholdAuto(high, low, oldest, i) : InpFVG_ThresholdPct / 100.0;

      double hi2 = high[i + 2];
      double lo2 = low[i + 2];
      double lo0 = low[i];
      double hi0 = high[i];
      double cl1 = close[i + 1];

      bool bull = (lo0 > hi2) && (cl1 > hi2) && (hi2 > 0.0) && (((lo0 - hi2) / hi2) > thr);
      bool bear = (hi0 < lo2) && (cl1 < lo2) && (hi0 > 0.0) && (((lo2 - hi0) / hi0) > thr);

      datetime tR = time[i] + (datetime)InpFVG_ExtendBars * sec;

      if(bull)
        {
         string nm = InpFVG_Prefix + "B_" + TimeToStr(time[i], TIME_DATE | TIME_SECONDS) + "_" + IntegerToString(i);
         FvgPushZone(nm, true, lo0, hi2, time[i + 2], tR);
        }
      if(bear)
        {
         string nm = InpFVG_Prefix + "S_" + TimeToStr(time[i], TIME_DATE | TIME_SECONDS) + "_" + IntegerToString(i);
         FvgPushZone(nm, false, lo2, hi0, time[i + 2], tR);
        }
     }
   G_fvg_last_bar_time = time[0];
  }

//+------------------------------------------------------------------+
void FvgUpdateIncremental(const datetime &time[], const double &high[], const double &low[], const double &close[], int rates_total)
  {
   if(!InpFVG_Show) return;
   FvgMitigateWithClose(close[0]);
   if(time[0] == G_fvg_last_bar_time) return;
   G_fvg_last_bar_time = time[0];

   int i = 1;
   if(i + 2 >= rates_total) return;

   int oldest = rates_total - 1;
   double thr = InpFVG_AutoThreshold ? FvgThresholdAuto(high, low, oldest, i) : InpFVG_ThresholdPct / 100.0;

   double hi2 = high[i + 2];
   double lo2 = low[i + 2];
   double lo0 = low[i];
   double hi0 = high[i];
   double cl1 = close[i + 1];

   bool bull = (lo0 > hi2) && (cl1 > hi2) && (hi2 > 0.0) && (((lo0 - hi2) / hi2) > thr);
   bool bear = (hi0 < lo2) && (cl1 < lo2) && (hi0 > 0.0) && (((lo2 - hi0) / hi0) > thr);

   datetime sec = FvgBarSeconds();
   datetime tR = time[i] + (datetime)InpFVG_ExtendBars * sec;

   if(bull)
     {
      string nm = InpFVG_Prefix + "B_" + TimeToStr(time[i], TIME_DATE | TIME_SECONDS) + "_L";
      FvgPushZone(nm, true, lo0, hi2, time[i + 2], tR);
     }
   if(bear)
     {
      string nm = InpFVG_Prefix + "S_" + TimeToStr(time[i], TIME_DATE | TIME_SECONDS) + "_L";
      FvgPushZone(nm, false, lo2, hi0, time[i + 2], tR);
     }
  }

//+------------------------------------------------------------------+
long ObVolAt(const long &volume[], const long &tick_volume[], int i)
  {
   long v = volume[i];
   if(v > 0) return(v);
   return(tick_volume[i]);
  }

//+------------------------------------------------------------------+
double LowestLowOB(const double &low[], int total, int shift, int len)
  {
   double v = low[shift];
   for(int k = 1; k < len && shift + k < total; k++)
      if(low[shift + k] < v) v = low[shift + k];
   return(v);
  }

//+------------------------------------------------------------------+
double HighestHighOB(const double &high[], int total, int shift, int len)
  {
   double v = high[shift];
   for(int k = 1; k < len && shift + k < total; k++)
      if(high[shift + k] > v) v = high[shift + k];
   return(v);
  }

//+------------------------------------------------------------------+
bool ObVolPivotHigh(const long &volume[], const long &tick_volume[], int total, int p, int L)
  {
   if(L < 1 || p - L < 0 || p + L > total - 1) return(false);
   long v0 = ObVolAt(volume, tick_volume, p);
   for(int k = 1; k <= L; k++)
     {
      if(ObVolAt(volume, tick_volume, p - k) >= v0) return(false);
      if(ObVolAt(volume, tick_volume, p + k) >= v0) return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
void ObDeletePair(ob_rec &z)
  {
   if(StringLen(z.name_rect) > 0) ObjectDelete(0, z.name_rect);
   if(StringLen(z.name_line) > 0) ObjectDelete(0, z.name_line);
  }

//+------------------------------------------------------------------+
void ObRemoveBullAt(int idx)
  {
   if(idx < 0 || idx >= G_ob_bull_n) return;
   ObDeletePair(G_ob_bulls[idx]);
   for(int k = idx; k < G_ob_bull_n - 1; k++)
      G_ob_bulls[k] = G_ob_bulls[k + 1];
   G_ob_bull_n--;
  }

//+------------------------------------------------------------------+
void ObRemoveBearAt(int idx)
  {
   if(idx < 0 || idx >= G_ob_bear_n) return;
   ObDeletePair(G_ob_bears[idx]);
   for(int k = idx; k < G_ob_bear_n - 1; k++)
      G_ob_bears[k] = G_ob_bears[k + 1];
   G_ob_bear_n--;
  }

//+------------------------------------------------------------------+
void ObMitigateBulls(const double target_bull)
  {
   for(int j = G_ob_bull_n - 1; j >= 0; j--)
      if(target_bull < G_ob_bulls[j].bot)
         ObRemoveBullAt(j);
  }

//+------------------------------------------------------------------+
void ObMitigateBears(const double target_bear)
  {
   for(int j = G_ob_bear_n - 1; j >= 0; j--)
      if(target_bear > G_ob_bears[j].top)
         ObRemoveBearAt(j);
  }

//+------------------------------------------------------------------+
void ObUnshiftBull(datetime tL, double top, double bot)
  {
   while(G_ob_bull_n >= InpOB_MaxZones) ObRemoveBullAt(G_ob_bull_n - 1);
   for(int k = G_ob_bull_n; k > 0; k--)
      G_ob_bulls[k] = G_ob_bulls[k - 1];
   G_ob_bulls[0].t_left = tL;
   G_ob_bulls[0].top = top;
   G_ob_bulls[0].bot = bot;
   G_ob_bulls[0].avg = (top + bot) * 0.5;
   G_ob_bulls[0].name_rect = "";
   G_ob_bulls[0].name_line = "";
   G_ob_bull_n++;
  }

//+------------------------------------------------------------------+
void ObUnshiftBear(datetime tL, double top, double bot)
  {
   while(G_ob_bear_n >= InpOB_MaxZones) ObRemoveBearAt(G_ob_bear_n - 1);
   for(int k = G_ob_bear_n; k > 0; k--)
      G_ob_bears[k] = G_ob_bears[k - 1];
   G_ob_bears[0].t_left = tL;
   G_ob_bears[0].top = top;
   G_ob_bears[0].bot = bot;
   G_ob_bears[0].avg = (top + bot) * 0.5;
   G_ob_bears[0].name_rect = "";
   G_ob_bears[0].name_line = "";
   G_ob_bear_n++;
  }

//+------------------------------------------------------------------+
int ObLineStylePick()
  {
   if(InpOB_LineStyle == 1) return(STYLE_DASH);
   if(InpOB_LineStyle == 2) return(STYLE_DOT);
   return(STYLE_SOLID);
  }

//+------------------------------------------------------------------+
bool ObEnsureGraphics(ob_rec &z, bool bull, int slot)
  {
   if(z.name_rect == "")
      z.name_rect = InpOB_Prefix + (bull ? "B_R_" : "S_R_") + IntegerToString(slot) + "_" + TimeToStr(z.t_left, TIME_DATE | TIME_SECONDS);
   if(z.name_line == "")
      z.name_line = InpOB_Prefix + (bull ? "B_L_" : "S_L_") + IntegerToString(slot) + "_" + TimeToStr(z.t_left, TIME_DATE | TIME_SECONDS);

   datetime tR = z.t_left + (datetime)InpOB_ExtendBars * FvgBarSeconds();
   if(ObjectFind(0, z.name_rect) < 0)
     {
      if(!ObjectCreate(0, z.name_rect, OBJ_RECTANGLE, 0, z.t_left, z.top, tR, z.bot)) return(false);
      ObjectSet(z.name_rect, OBJPROP_COLOR, bull ? InpOB_BullBorder : InpOB_BearBorder);
      ObjectSet(z.name_rect, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(z.name_rect, OBJPROP_WIDTH, 1);
      ObjectSet(z.name_rect, OBJPROP_BACK, true);
     }
   else
     {
      ObjectSet(z.name_rect, OBJPROP_TIME1, z.t_left);
      ObjectSet(z.name_rect, OBJPROP_PRICE1, z.top);
      ObjectSet(z.name_rect, OBJPROP_TIME2, tR);
      ObjectSet(z.name_rect, OBJPROP_PRICE2, z.bot);
     }

   if(ObjectFind(0, z.name_line) < 0)
     {
      if(!ObjectCreate(0, z.name_line, OBJ_TREND, 0, z.t_left, z.avg, tR, z.avg)) return(false);
      ObjectSet(z.name_line, OBJPROP_COLOR, bull ? InpOB_BullAvg : InpOB_BearAvg);
      ObjectSet(z.name_line, OBJPROP_STYLE, ObLineStylePick());
      ObjectSet(z.name_line, OBJPROP_WIDTH, InpOB_LineWidth);
      ObjectSet(z.name_line, OBJPROP_RAY_RIGHT, false);
      ObjectSet(z.name_line, OBJPROP_BACK, true);
     }
   else
     {
      ObjectSet(z.name_line, OBJPROP_TIME1, z.t_left);
      ObjectSet(z.name_line, OBJPROP_PRICE1, z.avg);
      ObjectSet(z.name_line, OBJPROP_TIME2, tR);
      ObjectSet(z.name_line, OBJPROP_PRICE2, z.avg);
     }
   return(true);
  }

//+------------------------------------------------------------------+
void ObRedrawVisible()
  {
   int nb = MathMin(InpOB_BullExt, G_ob_bull_n);
   for(int i = 0; i < nb; i++)
      ObEnsureGraphics(G_ob_bulls[i], true, i);
   int ne = MathMin(InpOB_BearExt, G_ob_bear_n);
   for(int i = 0; i < ne; i++)
      ObEnsureGraphics(G_ob_bears[i], false, i);
  }

//+------------------------------------------------------------------+
void ObRebuildFull(const datetime &time[], const double &high[], const double &low[],
                   const double &close[], const long &volume[], const long &tick_volume[],
                   int rates_total)
  {
   ObjectsDeleteAll(0, InpOB_Prefix);
   G_ob_bull_n = 0;
   G_ob_bear_n = 0;
   if(!InpOB_Show) return;

   int L = (int)MathMax(1, InpOB_Length);
   int oldest = rates_total - 1;
   int os = 0;

   for(int s = oldest; s >= 0; s--)
     {
      bool haveWin = (s + L - 1 <= oldest);
      bool haveHL  = (s + L <= oldest);

      double upper = 0.0, lower = 0.0;
      double target_bull = 0.0, target_bear = 0.0;

      if(haveWin)
        {
         upper = HighestHighOB(high, rates_total, s, L);
         lower = LowestLowOB(low, rates_total, s, L);
         if(InpOB_Mitigation == 1)
           {
            target_bull = LowestClose(close, rates_total, s, L);
            target_bear = HighestClose(close, rates_total, s, L);
           }
         else
           {
            target_bull = lower;
            target_bear = upper;
           }
        }

      if(haveWin && haveHL)
        {
         double hiL = high[s + L];
         double loL = low[s + L];
         if(hiL > upper) os = 0;
         else if(loL < lower) os = 1;
        }

      int p = s + L;
      bool phv = (p - L >= 0 && p + L <= oldest) &&
                 ObVolPivotHigh(volume, tick_volume, rates_total, p, L);

      if(phv && haveHL)
        {
         double h = high[p];
         double l = low[p];
         double hl2 = (h + l) * 0.5;
         if(os == 1)
            ObUnshiftBull(time[p], hl2, l);
         if(os == 0)
            ObUnshiftBear(time[p], h, hl2);
        }

      if(haveWin)
        {
         ObMitigateBulls(target_bull);
         ObMitigateBears(target_bear);
        }
     }

   ObRedrawVisible();
  }

double WMA_at(const double &src[], int total, int shift, int len)
  {
   if(len < 1 || shift < 0 || shift + len > total) return(0.0);
   double num = 0.0, den = 0.0;
   for(int k = 0; k < len; k++)
     {
      double w = (double)(len - k);
      num += src[shift + k] * w;
      den += w;
     }
   return(den > 0.0 ? num / den : 0.0);
  }

double VWMA_at(const double &src[], const long &vol[], int total, int shift, int len)
  {
   if(len < 1 || shift < 0 || shift + len > total) return(src[shift]);
   double num = 0.0, den = 0.0;
   for(int i = 0; i < len; i++)
     {
      double v = (double)vol[shift + i];
      num += src[shift + i] * v;
      den += v;
     }
   return(den > 0.0 ? num / den : src[shift]);
  }

double MA3BR_at(const double &src[], const long &vol[], int total, int shift, int len, int maType)
  {
   len = MathMax(1, len);
   if(shift + len >= total) return(src[shift]);
   if(maType == 0) return(iMA(NULL, 0, len, 0, MODE_SMA, PRICE_CLOSE, shift));
   if(maType == 1) return(iMA(NULL, 0, len, 0, MODE_EMA, PRICE_CLOSE, shift));
   if(maType == 2)
     {
      int half = MathMax(1, len / 2);
      int sq = (int)MathRound(MathSqrt(len));
      if(sq < 1) sq = 1;
      double w1 = WMA_at(src, total, shift, half);
      double w2 = WMA_at(src, total, shift, len);
      double base = 2.0 * w1 - w2;
      // Approximation of final WMA stage
      double arr[64];
      int n = MathMin(64, sq);
      for(int i = 0; i < n; i++)
        {
         int sh = shift + i;
         if(sh + len >= total) arr[i] = base;
         else
           {
            double a = WMA_at(src, total, sh, half);
            double b = WMA_at(src, total, sh, len);
            arr[i] = 2.0 * a - b;
           }
        }
      return(WMA_at(arr, n, 0, n));
     }
   if(maType == 3) return(iMA(NULL, 0, len, 0, MODE_SMMA, PRICE_CLOSE, shift)); // RMA approx
   if(maType == 4) return(iMA(NULL, 0, len, 0, MODE_LWMA, PRICE_CLOSE, shift)); // WMA
   return(VWMA_at(src, vol, total, shift, len)); // VWMA
  }

double HighestClose(const double &src[], int total, int shift, int len)
  {
   double v = src[shift];
   for(int i = 1; i < len && shift + i < total; i++)
      if(src[shift + i] > v) v = src[shift + i];
   return(v);
  }

double LowestClose(const double &src[], int total, int shift, int len)
  {
   double v = src[shift];
   for(int i = 1; i < len && shift + i < total; i++)
      if(src[shift + i] < v) v = src[shift + i];
   return(v);
  }

//+------------------------------------------------------------------+
// Pine ta.highest(9) / ta.lowest(9) from bar i through younger bars (series)
double RsHigh9(const double &high[], int total, int i)
  {
   int imax = MathMin(i + 8, total - 1);
   double v = high[i];
   for(int k = i + 1; k <= imax; k++)
      v = MathMax(v, high[k]);
   return(v);
  }

//+------------------------------------------------------------------+
double RsLow9(const double &low[], int total, int i)
  {
   int imax = MathMin(i + 8, total - 1);
   double v = low[i];
   for(int k = i + 1; k <= imax; k++)
      v = MathMin(v, low[k]);
   return(v);
  }

//+------------------------------------------------------------------+
void RsWarnRedraw(const datetime &time[], const double &close[], const double &high[],
                  const double &low[], int rates_total)
  {
   ObjectsDeleteAll(0, InpRS_WarnPrefix);
   if(!InpRS_Show || !InpRS_WarnFlip || rates_total < 10) return;

   int n = 0;
   int lim = MathMin(InpRS_WarnMaxBars, rates_total - 6);
   if(lim < 0) return;

   for(int i = 0; i <= lim && n < InpRS_WarnMaxMarks; i++)
     {
      if(i + 5 >= rates_total) break;
      bool c0 = (close[i] < close[i + 4]);
      bool c1 = (close[i + 1] < close[i + 5]);
      if(c0 == c1) continue;

      string nm = InpRS_WarnPrefix + IntegerToString(n);
      double span = high[i] - low[i];
      if(span <= 0.0) span = Point;
      double price = c0 ? (low[i] - span * 0.12) : (high[i] + span * 0.12);
      int code = c0 ? 234 : 233;
      if(ObjectFind(0, nm) >= 0) ObjectDelete(0, nm);
      if(!ObjectCreate(0, nm, OBJ_ARROW, 0, time[i], price)) continue;
      ObjectSet(nm, OBJPROP_ARROWCODE, code);
      ObjectSet(nm, OBJPROP_COLOR, c0 ? clrTomato : clrMediumSeaGreen);
      ObjectSet(nm, OBJPROP_WIDTH, 1);
      n++;
     }
  }

//+------------------------------------------------------------------+
void RsRun(const double &close[], const double &high[], const double &low[], int rates_total)
  {
   int oldest = rates_total - 1;
   int bSCR = 0, sSCR = 0;
   bool bSRR_ok = false;
   double bSRR = 0.0;
   bool sSSR_ok = false;
   double sSSR = 0.0;

   int ebSCR = 0, esSCR = 0;
   bool eRes_ok = false;
   double eRes = 0.0;
   bool eSup_ok = false;
   double eSup = 0.0;

   bool mrLo_ok = false, mrHi_ok = false;
   double mrLo = 0.0, mrHi = 0.0;
   bool erHi_ok = false, erLo_ok = false;
   double erHi = 0.0, erLo = 0.0;
   bool etLo_ok = false, etHi_ok = false;
   double etLo = 0.0, etHi = 0.0;

   int ts = InpRS_TradeSetup;
   if(ts < 0 || ts > 3) ts = 0;
   bool doMom = (ts != 2);
   bool doExh = (ts != 1);

   for(int i = oldest; i >= 0; i--)
     {
      BufRS_Bull[i] = EMPTY_VALUE;
      BufRS_Bear[i] = EMPTY_VALUE;
      BufRS_Res[i] = EMPTY_VALUE;
      BufRS_Sup[i] = EMPTY_VALUE;
      BufRS_ExBull[i] = EMPTY_VALUE;
      BufRS_ExBear[i] = EMPTY_VALUE;
      BufRS_ExRes[i] = EMPTY_VALUE;
      BufRS_ExSup[i] = EMPTY_VALUE;
      BufRS_MomRiskLo[i] = EMPTY_VALUE;
      BufRS_MomRiskHi[i] = EMPTY_VALUE;
      BufRS_ExRiskHi[i] = EMPTY_VALUE;
      BufRS_ExRiskLo[i] = EMPTY_VALUE;
      BufRS_ExTgtLo[i] = EMPTY_VALUE;
      BufRS_ExTgtHi[i] = EMPTY_VALUE;

      if(!InpRS_Show) continue;

      bool conRS = (i + 4 < rates_total) ? (close[i] < close[i + 4]) : false;
      int b0 = bSCR;
      int s0 = sSCR;
      if(conRS)
        {
         bSCR = (bSCR == 9 ? 1 : bSCR + 1);
         sSCR = 0;
        }
      else
        {
         sSCR = (sSCR == 9 ? 1 : sSCR + 1);
         bSCR = 0;
        }

      bool bullMom = (bSCR == 9);
      bool bearMom = (sSCR == 9);
      bool bullInc = conRS && ((bSCR > b0) || (b0 == 9 && bSCR == 1));
      bool bearInc = (!conRS) && ((sSCR > s0) || (s0 == 9 && sSCR == 1));

      double sRRS = RsHigh9(high, rates_total, i);
      double sSRS = RsLow9(low, rates_total, i);

      if(bSCR == 9)
        {
         bSRR = sRRS;
         bSRR_ok = true;
        }
      else
        {
         if(bSRR_ok && close[i] > bSRR) bSRR_ok = false;
        }

      if(sSCR == 9)
        {
         sSSR = sSRS;
         sSSR_ok = true;
        }
      else
        {
         if(sSSR_ok && close[i] < sSSR) sSSR_ok = false;
        }

      if(bSCR == 9)
        {
         mrLo = sSRS;
         mrLo_ok = true;
        }
      else if(mrLo_ok && close[i] < mrLo)
         mrLo_ok = false;

      if(sSCR == 9)
        {
         mrHi = sRRS;
         mrHi_ok = true;
        }
      else if(mrHi_ok && close[i] > mrHi)
         mrHi_ok = false;

      if(doMom && InpRS_MomMode != 2)
        {
         if(InpRS_MomMode == 0 && bullMom)
            BufRS_Bull[i] = low[i] - (high[i] - low[i]) * 0.08;
         else if(InpRS_MomMode == 1 && bullInc)
            BufRS_Bull[i] = low[i] - (high[i] - low[i]) * (0.022 + 0.006 * (double)bSCR);
         if(InpRS_MomMode == 0 && bearMom)
            BufRS_Bear[i] = high[i] + (high[i] - low[i]) * 0.08;
         else if(InpRS_MomMode == 1 && bearInc)
            BufRS_Bear[i] = high[i] + (high[i] - low[i]) * (0.022 + 0.006 * (double)sSCR);
        }

      if(doMom && InpRS_SRLevels && bSRR_ok)
         BufRS_Res[i] = bSRR;
      if(doMom && InpRS_SRLevels && sSSR_ok)
         BufRS_Sup[i] = sSSR;

      if(doMom && InpRS_MomRiskLevels && mrLo_ok)
         BufRS_MomRiskLo[i] = mrLo;
      if(doMom && InpRS_MomRiskLevels && mrHi_ok)
         BufRS_MomRiskHi[i] = mrHi;

      if(!InpRS_ExhaustShow) continue;

      bool conEx = (i + 4 < rates_total) ? (close[i] > close[i + 4]) : false;
      int eb0 = ebSCR;
      int es0 = esSCR;
      if(conEx)
        {
         ebSCR = (ebSCR == 9 ? 1 : ebSCR + 1);
         esSCR = 0;
        }
      else
        {
         esSCR = (esSCR == 9 ? 1 : esSCR + 1);
         ebSCR = 0;
        }

      bool exBull = (ebSCR == 9);
      bool exBear = (esSCR == 9);
      bool exBinc = conEx && ((ebSCR > eb0) || (eb0 == 9 && ebSCR == 1));
      bool exSinc = (!conEx) && ((esSCR > es0) || (es0 == 9 && esSCR == 1));

      double eHi = RsHigh9(high, rates_total, i);
      double eLo = RsLow9(low, rates_total, i);

      if(ebSCR == 9)
        {
         eSup = eLo;
         eSup_ok = true;
        }
      else
        {
         if(eSup_ok && close[i] < eSup) eSup_ok = false;
        }

      if(esSCR == 9)
        {
         eRes = eHi;
         eRes_ok = true;
        }
      else
        {
         if(eRes_ok && close[i] > eRes) eRes_ok = false;
        }

      if(ebSCR == 9)
        {
         erHi = eHi;
         erHi_ok = true;
         etLo = eLo;
         etLo_ok = true;
        }
      else
        {
         if(erHi_ok && close[i] > erHi) erHi_ok = false;
         if(etLo_ok && low[i] <= etLo) etLo_ok = false;
        }

      if(esSCR == 9)
        {
         erLo = eLo;
         erLo_ok = true;
         etHi = eHi;
         etHi_ok = true;
        }
      else
        {
         if(erLo_ok && close[i] < erLo) erLo_ok = false;
         if(etHi_ok && high[i] >= etHi) etHi_ok = false;
        }

      if(doExh && InpRS_ExMode != 2)
        {
         if(InpRS_ExMode == 0 && exBull)
            BufRS_ExBull[i] = low[i] - (high[i] - low[i]) * 0.1;
         else if(InpRS_ExMode == 1 && exBinc)
            BufRS_ExBull[i] = low[i] - (high[i] - low[i]) * (0.026 + 0.006 * (double)ebSCR);
         if(InpRS_ExMode == 0 && exBear)
            BufRS_ExBear[i] = high[i] + (high[i] - low[i]) * 0.1;
         else if(InpRS_ExMode == 1 && exSinc)
            BufRS_ExBear[i] = high[i] + (high[i] - low[i]) * (0.026 + 0.006 * (double)esSCR);
        }

      if(doExh && InpRS_ExSrLevels && eRes_ok)
         BufRS_ExRes[i] = eRes;
      if(doExh && InpRS_ExSrLevels && eSup_ok)
         BufRS_ExSup[i] = eSup;

      if(doExh && InpRS_ExRiskLevels && erHi_ok)
         BufRS_ExRiskHi[i] = erHi;
      if(doExh && InpRS_ExRiskLevels && erLo_ok)
         BufRS_ExRiskLo[i] = erLo;
      if(doExh && InpRS_ExTgtLevels && etLo_ok)
         BufRS_ExTgtLo[i] = etLo;
      if(doExh && InpRS_ExTgtLevels && etHi_ok)
         BufRS_ExTgtHi[i] = etHi;
     }
  }

//+------------------------------------------------------------------+
void SmcPivotStep(const double &high[], const double &low[], int total, int s, int L,
                  int &intra, double &topSwing, double &botSwing)
  {
   topSwing = 0.0;
   botSwing = 0.0;
   if(L < 1) return;
   int oldest = total - 1;
   if(s + L > oldest) return;
   double up = HighestHighOB(high, total, s, L);
   double dn = LowestLowOB(low, total, s, L);
   double cHi = high[s + L];
   double cLo = low[s + L];
   int prev = intra;
   if(cHi > up) intra = 0;
   else if(cLo < dn) intra = 1;
   if(intra == 0 && prev != 0) topSwing = cHi;
   if(intra == 1 && prev != 1) botSwing = cLo;
  }

//+------------------------------------------------------------------+
bool SmcStrExtOk(string str)
  {
   if(StringLen(str) < 1) return(false);
   if(InpSMC_ExtStru == 0) return(true);
   if(InpSMC_ExtStru == 1) return(str == "BoS");
   if(InpSMC_ExtStru == 2) return(str == "CHoCH");
   return(false);
  }

//+------------------------------------------------------------------+
bool SmcStrIntOk(string str)
  {
   if(StringLen(str) < 1) return(false);
   if(InpSMC_IntStru == 0) return(true);
   if(InpSMC_IntStru == 1) return(str == "I-BoS");
   if(InpSMC_IntStru == 2) return(str == "I-CHoCH");
   return(false);
  }

//+------------------------------------------------------------------+
void SmcDrawChar(int &objn, datetime tSwing, double y, datetime tBreak, string str, color c, bool labDn)
  {
   if(StringLen(str) < 1) return;
   if(objn + 2 > InpSMC_MaxObjects) return;
   objn++;
   string nmL = InpSMC_Prefix + "L" + IntegerToString(objn);
   objn++;
   string nmT = InpSMC_Prefix + "T" + IntegerToString(objn);
   if(ObjectFind(0, nmL) >= 0) ObjectDelete(0, nmL);
   if(ObjectFind(0, nmT) >= 0) ObjectDelete(0, nmT);
   if(!ObjectCreate(0, nmL, OBJ_TREND, 0, tSwing, y, tBreak, y)) return;
   ObjectSet(nmL, OBJPROP_COLOR, c);
   ObjectSet(nmL, OBJPROP_STYLE, STYLE_DOT);
   ObjectSet(nmL, OBJPROP_WIDTH, 1);
   ObjectSet(nmL, OBJPROP_BACK, true);

   double pad = MarketInfo(Symbol(), MODE_POINT) * 50.0;
   if(pad <= 0.0) pad = _Point * 50.0;
   double py = y + (labDn ? -pad : pad);
   if(!ObjectCreate(0, nmT, OBJ_TEXT, 0, tBreak, py)) return;
   ObjectSetText(nmT, str, 8, "Arial Bold", c);
   ObjectSet(nmT, OBJPROP_COLOR, c);
  }

//+------------------------------------------------------------------+
double SmcFibRatioK(const int k)
  {
   switch(k)
     {
      case 0: return(0.236);
      case 1: return(0.382);
      case 2: return(0.5);
      case 3: return(0.618);
      case 4: return(0.786);
      case 5: return(0.886);
      case 6: return(1.13);
      case 7: return(1.27);
      case 8: return(1.41);
      default: return(1.618);
     }
  }

//+------------------------------------------------------------------+
void SmcFibRedraw(const datetime &time[], int rates_total)
  {
   ObjectsDeleteAll(0, InpSMC_FibPrefix);
   if(!InpSMC_ShowFibs || !G_smc_fib_ok || rates_total < 3) return;

   double pt = MarketInfo(Symbol(), MODE_POINT);
   if(pt <= 0.0) pt = Point;
   datetime barSec = (datetime)Period() * 60;
   if(barSec < 1) barSec = 1;
   datetime tR = time[0] + (datetime)InpSMC_FibExtendBars * barSec;
   datetime tL = G_smc_fib_t_left;
   if(tL <= 0) tL = time[0];

   for(int k = 0; k < 10; k++)
     {
      double r = SmcFibRatioK(k);
      double y = G_smc_fib_base + G_smc_fib_span * r;
      string nm = InpSMC_FibPrefix + "ln" + IntegerToString(k);
      if(ObjectFind(0, nm) >= 0) ObjectDelete(0, nm);
      if(!ObjectCreate(0, nm, OBJ_TREND, 0, tL, y, tR, y)) continue;
      ObjectSet(nm, OBJPROP_COLOR, InpSMC_FibLineCol);
      ObjectSet(nm, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(nm, OBJPROP_WIDTH, 1);
      ObjectSet(nm, OBJPROP_BACK, true);

      string nm2 = InpSMC_FibPrefix + "tx" + IntegerToString(k);
      if(ObjectFind(0, nm2) >= 0) ObjectDelete(0, nm2);
      if(ObjectCreate(0, nm2, OBJ_TEXT, 0, tR, y))
        {
         string lab = DoubleToStr(r, 3);
         ObjectSetText(nm2, lab, 8, "Arial", InpSMC_FibTextCol);
         ObjectSet(nm2, OBJPROP_COLOR, InpSMC_FibTextCol);
        }
     }
  }

//+------------------------------------------------------------------+
void SmcRebuildFull(const datetime &time[], const double &high[], const double &low[], const double &close[], int rates_total)
  {
   ObjectsDeleteAll(0, InpSMC_Prefix);
   ObjectsDeleteAll(0, InpSMC_FibPrefix);
   G_smc_fib_ok = false;
   if(!InpSMC_Show) return;

   int exL = MathMax(3, MathMin(200, InpSMC_ExtSens));
   int inL = MathMax(3, MathMin(20, InpSMC_IntSens));
   int fibL = MathMax(5, MathMin(100, InpSMC_FibLen));
   int oldest = rates_total - 1;
   int objn = 0;

   int intraE = 0, intraI = 0, intraFib = 0;
   int moving = 0, movS = 0;
   int upside = 0, downside = 0, upSm = 0, dnSm = 0;
   double upAx = 0, dnAx = 0, upAxS = 0, dnAxS = 0;
   datetime upAxT = 0, dnAxT = 0, upAxTS = 0, dnAxTS = 0;
   bool haveUpAx = false, haveDnAx = false, haveUpS = false, haveDnS = false;

   for(int s = oldest; s >= 0; s--)
     {
      double topE = 0, botE = 0, topI = 0, botI = 0;
      SmcPivotStep(high, low, rates_total, s, exL, intraE, topE, botE);
      SmcPivotStep(high, low, rates_total, s, inL, intraI, topI, botI);

      double topFib = 0, botFib = 0;
      SmcPivotStep(high, low, rates_total, s, fibL, intraFib, topFib, botFib);

      if(topE > 0.0)
        {
         upside = 1;
         string lbl = (!haveUpAx || topE > upAx) ? "HH" : "LH";
         if(InpSMC_ShowHH && objn + 1 <= InpSMC_MaxObjects)
           {
            objn++;
            string nm = InpSMC_Prefix + "s" + IntegerToString(objn);
            double rng = high[s + exL] - low[s + exL];
            if(rng < Point * 5) rng = Point * 20;
            if(ObjectFind(0, nm) >= 0) ObjectDelete(0, nm);
            if(ObjectCreate(0, nm, OBJ_TEXT, 0, time[s + exL], topE + rng * 0.2))
               ObjectSetText(nm, lbl, 8, "Arial Bold", InpSMC_BearC);
           }
         upAx = topE;
         upAxT = time[s + exL];
         haveUpAx = true;
        }

      if(botE > 0.0)
        {
         downside = 1;
         string lbl = (!haveDnAx || botE < dnAx) ? "LL" : "HL";
         if(InpSMC_ShowLL && objn + 1 <= InpSMC_MaxObjects)
           {
            objn++;
            string nm = InpSMC_Prefix + "s" + IntegerToString(objn);
            double rng = high[s + exL] - low[s + exL];
            if(rng < Point * 5) rng = Point * 20;
            if(ObjectFind(0, nm) >= 0) ObjectDelete(0, nm);
            if(ObjectCreate(0, nm, OBJ_TEXT, 0, time[s + exL], botE - rng * 0.2))
               ObjectSetText(nm, lbl, 8, "Arial Bold", InpSMC_BullC);
           }
         dnAx = botE;
         dnAxT = time[s + exL];
         haveDnAx = true;
        }

      if(InpSMC_ShowExt)
        {
         if(upside != 0 && haveUpAx && (s + 1 < rates_total))
           {
            if(close[s] > upAx && close[s + 1] <= upAx)
              {
               string st = "";
               if(moving < 0) st = (InpSMC_ExtStru != 1) ? "CHoCH" : "";
               else st = (InpSMC_ExtStru != 2) ? "BoS" : "";
               if(StringLen(st) > 0 && SmcStrExtOk(st))
                  SmcDrawChar(objn, upAxT, upAx, time[s], st, InpSMC_BullC, true);
               upside = 0;
               moving = 1;
              }
           }
         if(downside != 0 && haveDnAx && (s + 1 < rates_total))
           {
            if(close[s] < dnAx && close[s + 1] >= dnAx)
              {
               string st = "";
               if(moving > 0) st = (InpSMC_ExtStru != 1) ? "CHoCH" : "";
               else st = (InpSMC_ExtStru != 2) ? "BoS" : "";
               if(StringLen(st) > 0 && SmcStrExtOk(st))
                  SmcDrawChar(objn, dnAxT, dnAx, time[s], st, InpSMC_BearC, false);
               downside = 0;
               moving = -1;
              }
           }
        }

      if(InpSMC_ShowInt)
        {
         if(topI > 0.0)
           {
            upSm = 1;
            upAxS = topI;
            upAxTS = time[s + inL];
            haveUpS = true;
           }
         if(botI > 0.0)
           {
            dnSm = 1;
            dnAxS = botI;
            dnAxTS = time[s + inL];
            haveDnS = true;
           }

         if(upSm != 0 && haveUpS && (s + 1 < rates_total))
           {
            if(close[s] > upAxS && close[s + 1] <= upAxS)
              {
               string st = "";
               if(movS < 0) st = (InpSMC_IntStru != 1) ? "I-CHoCH" : "";
               else st = (InpSMC_IntStru != 2) ? "I-BoS" : "";
               if(StringLen(st) > 0 && SmcStrIntOk(st))
                  SmcDrawChar(objn, upAxTS, upAxS, time[s], st, InpSMC_BullC, true);
               upSm = 0;
               movS = 1;
              }
           }
         if(dnSm != 0 && haveDnS && (s + 1 < rates_total))
           {
            if(close[s] < dnAxS && close[s + 1] >= dnAxS)
              {
               string st = "";
               if(movS > 0) st = (InpSMC_IntStru != 1) ? "I-CHoCH" : "";
               else st = (InpSMC_IntStru != 2) ? "I-BoS" : "";
               if(StringLen(st) > 0 && SmcStrIntOk(st))
                  SmcDrawChar(objn, dnAxTS, dnAxS, time[s], st, InpSMC_BearC, false);
               dnSm = 0;
               movS = -1;
              }
           }
        }

      if(s == 0 && InpSMC_ShowFibs)
        {
         G_smc_fib_ok = false;
         double pt = MarketInfo(Symbol(), MODE_POINT);
         if(pt <= 0.0) pt = Point;
         if(topFib > 0.0 && haveUpAx && haveDnAx)
           {
            double mlo = low[0];
            datetime mloT = time[0];
            for(int sh = 0; sh < rates_total; sh++)
              {
               if(time[sh] < dnAxT) break;
               if(low[sh] < mlo) { mlo = low[sh]; mloT = time[sh]; }
              }
            G_smc_fib_base = mlo;
            G_smc_fib_span = upAx - mlo;
            G_smc_fib_t_left = mloT;
            if(MathAbs(G_smc_fib_span) > pt * 10.0) G_smc_fib_ok = true;
           }
         else if(botFib > 0.0 && haveDnAx && haveUpAx)
           {
            double mhi = high[0];
            datetime mhiT = time[0];
            for(int sh = 0; sh < rates_total; sh++)
              {
               if(time[sh] < upAxT) break;
               if(high[sh] > mhi) { mhi = high[sh]; mhiT = time[sh]; }
              }
            G_smc_fib_base = mhi;
            G_smc_fib_span = dnAx - mhi;
            G_smc_fib_t_left = mhiT;
            if(MathAbs(G_smc_fib_span) > pt * 10.0) G_smc_fib_ok = true;
           }
        }
     }

   SmcFibRedraw(time, rates_total);
  }

//+------------------------------------------------------------------+
int RollBarsForMinutes(const int chartMin, const int targetMin)
  {
   int cm = chartMin;
   if(cm < 1) cm = 1;
   return((int)MathMax(2, (targetMin + cm - 1) / cm));
  }

//+------------------------------------------------------------------+
void RollTrend(const string tag, datetime tL, double pr, datetime tR, color c)
  {
   string nm = InpRoll_Prefix + tag;
   if(ObjectFind(0, nm) >= 0) ObjectDelete(0, nm);
   if(!ObjectCreate(0, nm, OBJ_TREND, 0, tL, pr, tR, pr)) return;
   ObjectSet(nm, OBJPROP_COLOR, c);
   ObjectSet(nm, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(nm, OBJPROP_WIDTH, 1);
   ObjectSet(nm, OBJPROP_BACK, true);
  }

//+------------------------------------------------------------------+
void RollLabel(const string tag, datetime t, double pr, string txt, color c)
  {
   string nm = InpRoll_Prefix + "lb_" + tag;
   if(ObjectFind(0, nm) >= 0) ObjectDelete(0, nm);
   if(!ObjectCreate(0, nm, OBJ_TEXT, 0, t, pr)) return;
   ObjectSetText(nm, txt, 7, "Arial", c);
   ObjectSet(nm, OBJPROP_COLOR, c);
  }

//+------------------------------------------------------------------+
void RollMaxHighTie(const double &high[], const datetime &time[], const int n,
                    double &mx, datetime &mxT)
  {
   mx = high[0];
   for(int k = 1; k < n; k++)
      if(high[k] > mx) mx = high[k];
   double pt = MarketInfo(Symbol(), MODE_POINT);
   if(pt <= 0.0) pt = Point;
   double tol = MathMax(pt * 10.0, MathAbs(mx) * 1.0e-10);
   mxT = time[0];
   bool ok = false;
   for(int k = 0; k < n; k++)
     {
      if(MathAbs(high[k] - mx) > tol) continue;
      if(!ok || time[k] < mxT) { mxT = time[k]; ok = true; }
     }
   if(!ok) mxT = time[0];
  }

//+------------------------------------------------------------------+
void RollMinLowTie(const double &low[], const datetime &time[], const int n,
                   double &mn, datetime &mnT)
  {
   mn = low[0];
   for(int k = 1; k < n; k++)
      if(low[k] < mn) mn = low[k];
   double pt = MarketInfo(Symbol(), MODE_POINT);
   if(pt <= 0.0) pt = Point;
   double tol = MathMax(pt * 10.0, MathAbs(mn) * 1.0e-10);
   mnT = time[0];
   bool ok = false;
   for(int k = 0; k < n; k++)
     {
      if(MathAbs(low[k] - mn) > tol) continue;
      if(!ok || time[k] < mnT) { mnT = time[k]; ok = true; }
     }
   if(!ok) mnT = time[0];
  }

//+------------------------------------------------------------------+
void RollHtfRedraw(const datetime &time[], const double &high[], const double &low[], int rates_total)
  {
   ObjectsDeleteAll(0, InpRoll_Prefix);
   if((!InpRoll4H && !InpRoll1D) || rates_total < 3) return;

   datetime barSec = FvgBarSeconds();
   if(barSec < 1) barSec = 1;
   datetime tR = time[0] + (datetime)InpRoll_ExtendBars * barSec;

   int pm = Period();
   if(pm < 1) pm = 1;

   if(pm > 60)
     {
      if(InpRoll4H)
        {
         datetime t4 = iTime(NULL, PERIOD_H4, 1);
         if(t4 > 0)
           {
            double h4 = iHigh(NULL, PERIOD_H4, 1);
            double l4 = iLow(NULL, PERIOD_H4, 1);
            RollTrend("h4H", t4, h4, tR, InpRoll4H_HiCol);
            RollTrend("h4L", t4, l4, tR, InpRoll4H_LoCol);
            if(InpRoll4H_Labels)
              {
               RollLabel("h4H", tR, h4, "H4-H", InpRoll4H_HiCol);
               RollLabel("h4L", tR, l4, "H4-L", InpRoll4H_LoCol);
              }
           }
        }
      if(InpRoll1D)
        {
         datetime td = iTime(NULL, PERIOD_D1, 1);
         if(td > 0)
           {
            double hd = iHigh(NULL, PERIOD_D1, 1);
            double ld = iLow(NULL, PERIOD_D1, 1);
            RollTrend("d1H", td, hd, tR, InpRoll1D_HiCol);
            RollTrend("d1L", td, ld, tR, InpRoll1D_LoCol);
            if(InpRoll1D_Labels)
              {
               RollLabel("d1H", tR, hd, "D1-H", InpRoll1D_HiCol);
               RollLabel("d1L", tR, ld, "D1-L", InpRoll1D_LoCol);
              }
           }
        }
      return;
     }

   int n4 = RollBarsForMinutes(pm, 240);
   int nD = RollBarsForMinutes(pm, 1440);
   n4 = MathMin(n4, rates_total);
   nD = MathMin(nD, rates_total);

   double mx, mn;
   datetime mxT, mnT;

   if(InpRoll4H)
     {
      RollMaxHighTie(high, time, n4, mx, mxT);
      RollMinLowTie(low, time, n4, mn, mnT);
      RollTrend("r4H", mxT, mx, tR, InpRoll4H_HiCol);
      RollTrend("r4L", mnT, mn, tR, InpRoll4H_LoCol);
      if(InpRoll4H_Labels)
        {
         RollLabel("r4H", tR, mx, "240H", InpRoll4H_HiCol);
         RollLabel("r4L", tR, mn, "240L", InpRoll4H_LoCol);
        }
     }

   if(InpRoll1D)
     {
      RollMaxHighTie(high, time, nD, mx, mxT);
      RollMinLowTie(low, time, nD, mn, mnT);
      RollTrend("r1H", mxT, mx, tR, InpRoll1D_HiCol);
      RollTrend("r1L", mnT, mn, tR, InpRoll1D_LoCol);
      if(InpRoll1D_Labels)
        {
         RollLabel("r1H", tR, mx, "1440H", InpRoll1D_HiCol);
         RollLabel("r1L", tR, mn, "1440L", InpRoll1D_LoCol);
        }
     }
  }

//+------------------------------------------------------------------+
datetime SessGmtClock()
  {
   datetime g = TimeGMT();
   if(g <= 0) g = TimeCurrent();
   return(g);
  }

//+------------------------------------------------------------------+
void SessNyHM(const int addMin, int &nh, int &nm)
  {
   datetime g = SessGmtClock();
   int gmtMin = TimeHour(g) * 60 + TimeMinute(g);
   int total = gmtMin + addMin;
   total = (total % 1440 + 1440) % 1440;
   nh = total / 60;
   nm = total % 60;
  }

//+------------------------------------------------------------------+
bool SessIsNY(const int nh, const int nm)
  {
   int c = nh * 60 + nm;
   return(c >= 9 * 60 + 30 && c <= 16 * 60);
  }

//+------------------------------------------------------------------+
bool SessIsAsia(const int nh, const int nm)
  {
   int c = nh * 60 + nm;
   return(c >= 20 * 60 || c <= 2 * 60);
  }

//+------------------------------------------------------------------+
bool SessIsLondon(const int nh, const int nm)
  {
   int c = nh * 60 + nm;
   return(c >= 3 * 60 && c <= 11 * 60 + 30);
  }

//+------------------------------------------------------------------+
int SessMinsToClose(const int nh, const int nm)
  {
   int c = nh * 60 + nm;
   if(SessIsNY(nh, nm)) return(16 * 60 - c);
   if(SessIsLondon(nh, nm)) return(11 * 60 + 30 - c);
   if(SessIsAsia(nh, nm))
     {
      if(c >= 20 * 60) return(24 * 60 - c + 2 * 60);
      return(2 * 60 - c);
     }
   return(-1);
  }

//+------------------------------------------------------------------+
string SessPad2(const int v)
  {
   if(v < 10) return("0" + IntegerToString(v));
   return(IntegerToString(v));
  }

//+------------------------------------------------------------------+
double SessSumVol(const long &tv[], const int total, const int n)
  {
   double s = 0.0;
   for(int i = 0; i < n && i < total; i++)
      s += (double)tv[i];
   return(s);
  }

//+------------------------------------------------------------------+
void SessRedraw(const long &tick_volume[], const int rates_total)
  {
   if(!InpSess_Show)
     {
      ObjectsDeleteAll(0, InpSess_Prefix);
      return;
     }

   int nh = 0, nm = 0;
   SessNyHM(InpSess_NY_OffsetMin, nh, nm);

   string sess = "Dead Zone";
   string nextS = "New York";
   if(SessIsNY(nh, nm)) { sess = "New York"; nextS = "Asia"; }
   else if(SessIsAsia(nh, nm)) { sess = "Asia"; nextS = "London"; }
   else if(SessIsLondon(nh, nm)) { sess = "London"; nextS = "New York"; }
   else
     {
      if(nh > 16 || nh < 3) nextS = "London";
      else if(nh >= 11 && nh < 20) nextS = "Asia";
      else nextS = "New York";
     }

   int mc = SessMinsToClose(nh, nm);
   string sClose = "n/a";
   if(mc >= 0) sClose = IntegerToString(mc / 60) + "h" + SessPad2(mc % 60) + "m";

   int pm = Period();
   if(pm < 1) pm = 1;
   int n4 = RollBarsForMinutes(pm, 240);
   int nD = RollBarsForMinutes(pm, 1440);
   n4 = MathMin(n4, rates_total);
   nD = MathMin(nD, rates_total);
   double v4 = SessSumVol(tick_volume, rates_total, n4);
   double vD = SessSumVol(tick_volume, rates_total, nD);

   string row0 = "NY " + SessPad2(nh) + ":" + SessPad2(nm) + "  (GMT" + (InpSess_NY_OffsetMin >= 0 ? "+" : "") + IntegerToString(InpSess_NY_OffsetMin) + "m)";
   string row1 = "Session: " + sess;
   string row2 = "To session end: " + sClose;
   string row3 = "Next focus: " + nextS;
   string row4 = "4H roll sum V: " + DoubleToStr(v4, 0);
   string row5 = "1D roll sum V: " + DoubleToStr(vD, 0);
   string row6 = "Pine tab2 (simplified)";
   string row7 = "Set offset for EDT=-240";

   for(int i = 0; i < 8; i++)
     {
      string nm = InpSess_Prefix + "L" + IntegerToString(i);
      if(ObjectFind(0, nm) < 0)
        {
         if(!ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0)) continue;
         ObjectSet(nm, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
         ObjectSet(nm, OBJPROP_XDISTANCE, InpSess_XDist);
         ObjectSet(nm, OBJPROP_YDISTANCE, InpSess_YDist + i * InpSess_LineH);
        }
      string txt = row0;
      if(i == 1) txt = row1;
      else if(i == 2) txt = row2;
      else if(i == 3) txt = row3;
      else if(i == 4) txt = row4;
      else if(i == 5) txt = row5;
      else if(i == 6) txt = row6;
      else if(i == 7) txt = row7;
      ObjectSetText(nm, txt, 9, "Arial", clrWhite);
      ObjectSet(nm, OBJPROP_COLOR, clrWhite);
     }
  }

//+------------------------------------------------------------------+
//| Bar open time (server) + offset → same NY/Asia/London rules as tab |
//+------------------------------------------------------------------+
void SessNyHMFromBar(const datetime t, const int addMin, int &nh, int &nm)
  {
   int m = TimeHour(t) * 60 + TimeMinute(t) + addMin;
   m = (m % 1440 + 1440) % 1440;
   nh = m / 60;
   nm = m % 60;
  }

//+------------------------------------------------------------------+
int SessClassFromHM(const int nh, const int nm)
  {
   if(SessIsNY(nh, nm)) return(1);
   if(SessIsAsia(nh, nm)) return(2);
   if(SessIsLondon(nh, nm)) return(3);
   return(0);
  }

//+------------------------------------------------------------------+
void SessEmitRect(int &oid, const string sfx, const datetime tL, const datetime tR, const int cls)
  {
   if(cls <= 0) return;
   if(oid > 400) return;
   color c = (cls == 1) ? InpSess_BgNY : ((cls == 2) ? InpSess_BgAsia : InpSess_BgLondon);
   string ob = InpSess_BgPrefix + sfx + IntegerToString(oid);
   oid++;
   double y1 = ChartGetDouble(0, CHART_PRICE_MAX);
   double y2 = ChartGetDouble(0, CHART_PRICE_MIN);
   if(y1 <= y2)
     {
      double mid = (Bid + Ask) * 0.5;
      if(mid <= 0.0) mid = iClose(Symbol(), Period(), 0);
      y1 = mid + 5000.0 * Point;
      y2 = mid - 5000.0 * Point;
     }
   FvgCreateRect(ob, tL, tR, y1, y2, c);
  }

//+------------------------------------------------------------------+
void SessBgRedraw(const datetime &time[], const int rates_total)
  {
   ObjectsDeleteAll(0, InpSess_BgPrefix);
   if(!InpSess_BgShow || rates_total < 2) return;

   int W = MathMin(InpSess_BgMaxBars, rates_total - 1);
   if(W < 0) return;

   int nh = 0, nm = 0;
   SessNyHMFromBar(time[W], InpSess_NY_OffsetMin, nh, nm);
   int cur = SessClassFromHM(nh, nm);
   int segStart = W;
   int oid = 0;
   datetime barSec = FvgBarSeconds();
   if(barSec < 1) barSec = 1;

   for(int i = W - 1; i >= 0; i--)
     {
      SessNyHMFromBar(time[i], InpSess_NY_OffsetMin, nh, nm);
      int c = SessClassFromHM(nh, nm);
      if(c != cur)
        {
         if(cur > 0)
           {
            datetime tL = time[segStart];
            datetime tR = time[i + 1] + barSec;
            if(tR > tL)
               SessEmitRect(oid, "g", tL, tR, cur);
           }
         cur = c;
         segStart = i;
        }
     }

   if(cur > 0)
     {
      datetime tL = time[segStart];
      datetime tR = time[0] + barSec;
      if(tR > tL)
         SessEmitRect(oid, "g", tL, tR, cur);
     }
  }

int OnInit()
  {
   SetIndexBuffer(0, BufHull);
   SetIndexBuffer(1, BufHull2);
   SetIndexBuffer(2, BufTrail);
   SetIndexBuffer(3, BufBuy);
   SetIndexBuffer(4, BufSell);
   SetIndexBuffer(5, Buf3BRBull);
   SetIndexBuffer(6, Buf3BRBear);
   SetIndexBuffer(7, Buf3BRBullSR);
   SetIndexBuffer(8, Buf3BRBearSR);
   SetIndexBuffer(9, BufRaw);
   SetIndexBuffer(10, BufRS_Bull);
   SetIndexBuffer(11, BufRS_Bear);
   SetIndexBuffer(12, BufRS_Res);
   SetIndexBuffer(13, BufRS_Sup);
   SetIndexBuffer(14, BufRS_ExBull);
   SetIndexBuffer(15, BufRS_ExBear);
   SetIndexBuffer(16, BufRS_ExRes);
   SetIndexBuffer(17, BufRS_ExSup);
   SetIndexBuffer(18, BufRS_MomRiskLo);
   SetIndexBuffer(19, BufRS_MomRiskHi);
   SetIndexBuffer(20, BufRS_ExRiskHi);
   SetIndexBuffer(21, BufRS_ExRiskLo);
   SetIndexBuffer(22, BufRS_ExTgtLo);
   SetIndexBuffer(23, BufRS_ExTgtHi);

   SetIndexArrow(3, 233);
   SetIndexArrow(4, 234);
   SetIndexArrow(5, 233);
   SetIndexArrow(6, 234);
   SetIndexArrow(10, 233);
   SetIndexArrow(11, 234);
   SetIndexArrow(14, 181);
   SetIndexArrow(15, 182);
   SetIndexStyle(9, DRAW_NONE);

   for(int i = 0; i < 24; i++) SetIndexEmptyValue(i, EMPTY_VALUE);
   IndicatorShortName("SMC_Flow_UT_Hull_3BR_FVG_OB_RS3_SMC_FIB_RL_TAB_SBG");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, InpFVG_Prefix);
   ObjectsDeleteAll(0, InpOB_Prefix);
   ObjectsDeleteAll(0, InpSMC_Prefix);
   ObjectsDeleteAll(0, InpSMC_FibPrefix);
   ObjectsDeleteAll(0, InpRoll_Prefix);
   ObjectsDeleteAll(0, InpSess_Prefix);
   ObjectsDeleteAll(0, InpSess_BgPrefix);
   ObjectsDeleteAll(0, InpRS_WarnPrefix);
   G_fvg_n = 0;
   G_ob_bull_n = 0;
   G_ob_bear_n = 0;
  }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total < 500) return(0);

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);
   ArraySetAsSeries(volume, true);

   ArraySetAsSeries(BufHull, true);
   ArraySetAsSeries(BufHull2, true);
   ArraySetAsSeries(BufTrail, true);
   ArraySetAsSeries(BufBuy, true);
   ArraySetAsSeries(BufSell, true);
   ArraySetAsSeries(Buf3BRBull, true);
   ArraySetAsSeries(Buf3BRBear, true);
   ArraySetAsSeries(Buf3BRBullSR, true);
   ArraySetAsSeries(Buf3BRBearSR, true);
   ArraySetAsSeries(BufRaw, true);
   ArraySetAsSeries(BufRS_Bull, true);
   ArraySetAsSeries(BufRS_Bear, true);
   ArraySetAsSeries(BufRS_Res, true);
   ArraySetAsSeries(BufRS_Sup, true);
   ArraySetAsSeries(BufRS_ExBull, true);
   ArraySetAsSeries(BufRS_ExBear, true);
   ArraySetAsSeries(BufRS_ExRes, true);
   ArraySetAsSeries(BufRS_ExSup, true);
   ArraySetAsSeries(BufRS_MomRiskLo, true);
   ArraySetAsSeries(BufRS_MomRiskHi, true);
   ArraySetAsSeries(BufRS_ExRiskHi, true);
   ArraySetAsSeries(BufRS_ExRiskLo, true);
   ArraySetAsSeries(BufRS_ExTgtLo, true);
   ArraySetAsSeries(BufRS_ExTgtHi, true);

   static double src[];
   static double haO[];
   static double haC[];
   ArrayResize(src, rates_total);
   ArrayResize(haO, rates_total);
   ArrayResize(haC, rates_total);
   ArraySetAsSeries(src, true);
   ArraySetAsSeries(haO, true);
   ArraySetAsSeries(haC, true);

   int oldest = rates_total - 1;
   for(int i = oldest; i >= 0; i--)
     {
      haC[i] = (open[i] + high[i] + low[i] + close[i]) / 4.0;
      if(i == oldest) haO[i] = (open[i] + close[i]) / 2.0;
      else haO[i] = (haO[i + 1] + haC[i + 1]) / 2.0;
      src[i] = InpUT_UseHeikinAshi ? haC[i] : close[i];

      BufHull[i] = EMPTY_VALUE;
      BufHull2[i] = EMPTY_VALUE;
      BufTrail[i] = EMPTY_VALUE;
      BufBuy[i] = EMPTY_VALUE;
      BufSell[i] = EMPTY_VALUE;
      Buf3BRBull[i] = EMPTY_VALUE;
      Buf3BRBear[i] = EMPTY_VALUE;
      Buf3BRBullSR[i] = EMPTY_VALUE;
      Buf3BRBearSR[i] = EMPTY_VALUE;
      BufRaw[i] = EMPTY_VALUE;
     }

   // ===== UT BOT =====
   static double trail[];
   ArrayResize(trail, rates_total);
   ArraySetAsSeries(trail, true);
   trail[oldest] = src[oldest];
   for(int i = oldest - 1; i >= 0; i--)
     {
      double atr = iATR(NULL, 0, InpUT_ATRPeriod, i);
      if(atr <= 0.0) { trail[i] = trail[i + 1]; continue; }
      double nLoss = (double)InpUT_Key * atr;
      double s0 = src[i], s1 = src[i + 1], prev = trail[i + 1];
      if(s0 > prev && s1 > prev) trail[i] = MathMax(prev, s0 - nLoss);
      else if(s0 < prev && s1 < prev) trail[i] = MathMin(prev, s0 + nLoss);
      else if(s0 > prev) trail[i] = s0 - nLoss;
      else trail[i] = s0 + nLoss;

      if(InpShowUT) BufTrail[i] = trail[i];
      if(InpShowUT && InpShowUTSignals && i + 2 < rates_total)
        {
         double tr = trail[i], tr1 = trail[i + 1];
         bool above = (s0 > tr && s1 <= tr1);
         bool below = (tr > s0 && tr1 <= s1);
         bool buy = (s0 > tr && above);
         bool sell = (s0 < tr && below);
         if(buy) BufBuy[i] = low[i] - (high[i] - low[i]) * 0.1;
         if(sell) BufSell[i] = high[i] + (high[i] - low[i]) * 0.1;
        }
     }

   // ===== HULL =====
   int Lh = (int)MathMax(2, MathFloor(InpHull_Length * InpHull_Mult));
   int half = MathMax(1, Lh / 2);
   int sq = (int)MathRound(MathSqrt(Lh));
   if(sq < 1) sq = 1;

   for(int i = oldest - (Lh + sq + 10); i >= 0; i--)
     {
      if(i + Lh + sq >= rates_total) continue;
      double w1 = WMA_at(src, rates_total, i, half);
      double w2 = WMA_at(src, rates_total, i, Lh);
      BufRaw[i] = 2.0 * w1 - w2;
     }
   for(int i = oldest - (Lh + sq + 10); i >= 0; i--)
     {
      if(i + sq >= rates_total || BufRaw[i] == EMPTY_VALUE) continue;
      if(InpShowHull) BufHull[i] = WMA_at(BufRaw, rates_total, i, sq);
      if(InpShowHullBand && i + 2 < rates_total && BufHull[i + 2] != EMPTY_VALUE)
         BufHull2[i] = BufHull[i + 2];
     }

   // ===== 3BR Trend Precompute =====
   static double maFast[], maSlow[], stUpper[], stLower[], stDir[], dcOs[];
   ArrayResize(maFast, rates_total);
   ArrayResize(maSlow, rates_total);
   ArrayResize(stUpper, rates_total);
   ArrayResize(stLower, rates_total);
   ArrayResize(stDir, rates_total);
   ArrayResize(dcOs, rates_total);
   ArraySetAsSeries(maFast, true);
   ArraySetAsSeries(maSlow, true);
   ArraySetAsSeries(stUpper, true);
   ArraySetAsSeries(stLower, true);
   ArraySetAsSeries(stDir, true);
   ArraySetAsSeries(dcOs, true);

   for(int i = oldest - 1; i >= 0; i--)
     {
      maFast[i] = MA3BR_at(close, tick_volume, rates_total, i, Inp3BR_MAFastLen, Inp3BR_MAType);
      maSlow[i] = MA3BR_at(close, tick_volume, rates_total, i, Inp3BR_MASlowLen, Inp3BR_MAType);

      double atr = iATR(NULL, 0, Inp3BR_ATRPeriod, i);
      double mid = (high[i] + low[i]) * 0.5;
      double bUp = mid + Inp3BR_Factor * atr;
      double bDn = mid - Inp3BR_Factor * atr;

      if(i == oldest - 1)
        {
         stUpper[i] = bUp;
         stLower[i] = bDn;
         stDir[i] = 1.0;
         dcOs[i] = 0.0;
        }
      else
        {
         stUpper[i] = (bUp < stUpper[i + 1] || close[i + 1] > stUpper[i + 1]) ? bUp : stUpper[i + 1];
         stLower[i] = (bDn > stLower[i + 1] || close[i + 1] < stLower[i + 1]) ? bDn : stLower[i + 1];
         double d = stDir[i + 1];
         if(close[i] > stUpper[i + 1]) d = -1.0;
         else if(close[i] < stLower[i + 1]) d = 1.0;
         stDir[i] = d;

         double upNow = HighestClose(close, rates_total, i, Inp3BR_DonLen);
         double upPrev = HighestClose(close, rates_total, i + 1, Inp3BR_DonLen);
         double dnNow = LowestClose(close, rates_total, i, Inp3BR_DonLen);
         double dnPrev = LowestClose(close, rates_total, i + 1, Inp3BR_DonLen);
         double os = dcOs[i + 1];
         if(upNow > upPrev) os = 1.0;
         else if(dnNow < dnPrev) os = 0.0;
         dcOs[i] = os;
        }
     }

   // ===== Three Bar Reversal Core =====
   bool bullPending = false, bearPending = false;
   bool bullActive = false, bearActive = false;
   double bullTop = 0.0, bullBottom = 0.0;
   double bearTop = 0.0, bearBottom = 0.0;
   double bullSRLevel = EMPTY_VALUE, bearSRLevel = EMPTY_VALUE;

   for(int i = oldest - 3; i >= 0; i--)
     {
      bool upTrend = true, downTrend = true;
      if(Inp3BR_TrendType == 1) // MA cloud
        {
         if(Inp3BR_TrendFilt == 0)
           {
            downTrend = close[i] < maFast[i] && maFast[i] < maSlow[i];
            upTrend   = close[i] > maFast[i] && maFast[i] > maSlow[i];
           }
         else
           {
            downTrend = close[i] > maFast[i] && maFast[i] > maSlow[i];
            upTrend   = close[i] < maFast[i] && maFast[i] < maSlow[i];
           }
        }
      else if(Inp3BR_TrendType == 2) // supertrend
        {
         if(Inp3BR_TrendFilt == 0) { downTrend = stDir[i] > 0; upTrend = stDir[i] < 0; }
         else { downTrend = stDir[i] < 0; upTrend = stDir[i] > 0; }
        }
      else if(Inp3BR_TrendType == 3) // donchian
        {
         if(Inp3BR_TrendFilt == 0) { downTrend = dcOs[i] == 0.0; upTrend = dcOs[i] == 1.0; }
         else { downTrend = dcOs[i] == 1.0; upTrend = dcOs[i] == 0.0; }
        }

      bool baseBull = (close[i + 2] < open[i + 2]) &&
                      (low[i + 1] < low[i + 2]) && (high[i + 1] < high[i + 2]) &&
                      (close[i + 1] < open[i + 1]) &&
                      (close[i] > open[i]) && (high[i] > high[i + 2]) &&
                      upTrend;

      bool baseBear = (close[i + 2] > open[i + 2]) &&
                      (high[i + 1] > high[i + 2]) && (low[i + 1] > low[i + 2]) &&
                      (close[i + 1] > open[i + 1]) &&
                      (close[i] < open[i]) && (low[i] < low[i + 2]) &&
                      downTrend;

      bool bullEnhanced = close[i] > high[i + 2];
      bool bearEnhanced = close[i] < low[i + 2];
      bool bullAllowed = (Inp3BR_PatternType == 0) || (Inp3BR_PatternType == 1 && !bullEnhanced) || (Inp3BR_PatternType == 2 && bullEnhanced);
      bool bearAllowed = (Inp3BR_PatternType == 0) || (Inp3BR_PatternType == 1 && !bearEnhanced) || (Inp3BR_PatternType == 2 && bearEnhanced);
      bool bullTrig = InpShow3BR && baseBull && bullAllowed;
      bool bearTrig = InpShow3BR && baseBear && bearAllowed;

      if(bullTrig)
        {
         bullPending = true;
         bullTop = high[i + 2];
         bullBottom = MathMin(low[i + 1], low[i]);
        }

      if(bearTrig)
        {
         bearPending = true;
         bearBottom = low[i + 2];
         bearTop = MathMax(high[i + 1], high[i]);
        }

      if(bullPending)
        {
         if(close[i + 1] > bullTop)
           {
            Buf3BRBull[i + 1] = low[i + 1] - (high[i + 1] - low[i + 1]) * 0.12;
            bullPending = false;
            if(Inp3BR_SRMode != 2) { bullActive = true; bullSRLevel = bullBottom; }
           }
         else if(close[i + 1] < bullBottom || bearTrig)
            bullPending = false;
        }

      if(bearPending)
        {
         if(close[i + 1] > bearTop || bullTrig)
            bearPending = false;
         else if(close[i + 1] < bearBottom)
           {
            Buf3BRBear[i + 1] = high[i + 1] + (high[i + 1] - low[i + 1]) * 0.12;
            bearPending = false;
            if(Inp3BR_SRMode != 2) { bearActive = true; bearSRLevel = bearTop; }
           }
        }

      if(bullActive)
        {
         if(close[i] > bullBottom) Buf3BRBullSR[i] = bullSRLevel;
         else bullActive = false;
        }
      if(bearActive)
        {
         if(close[i] < bearTop) Buf3BRBearSR[i] = bearSRLevel;
         else bearActive = false;
        }
     }

   RsRun(close, high, low, rates_total);
   RsWarnRedraw(time, close, high, low, rates_total);
   SmcRebuildFull(time, high, low, close, rates_total);

   if(prev_calculated == 0)
      FvgRebuildFull(time, high, low, close, rates_total);
   else
      FvgUpdateIncremental(time, high, low, close, rates_total);

   ObRebuildFull(time, high, low, close, volume, tick_volume, rates_total);
   RollHtfRedraw(time, high, low, rates_total);
   SessRedraw(tick_volume, rates_total);
   SessBgRedraw(time, rates_total);

   return(rates_total);
  }
//+------------------------------------------------------------------+
