The original code cannot be directly run on MT4. 
To facilitate its use on MT4, a simple ported version was created, which includes some basic functions such as the buy/sell arrows and fvg.


对照清单（截至目前）
✅ 已完成（功能可用）
🟡 近似完成（MT4 限制下替代实现）
❌ 未完成（或仅占位）
1) Smart Money Concepts / Swing / Structure
✅ 内部/外部结构（BoS/CHoCH）
✅ HH/LH、HL/LL 标签
✅ 灵敏度参数（int/ext）
✅ 结构显示过滤（All/BoS/CHoCH）
2) Auto Fibs
✅ 主腿识别与 Fib 绘制
✅ 10 级别开关（show1..show10 对应）
✅ 10 级别比例参数（fib1..fib10 对应）
✅ 10 级别颜色参数（fib1col..fib10col 对应）
✅ 右侧延伸与文本标注
3) Rolling HTF High/Low（4H / 1D）
✅ 4H/1D 高低线与标签
🟡 在低周期图“滚动窗口”近似 request.security 行为
🟡 高周期下使用上一根已收盘 H4/D1 替代路径
4) Sessions
✅ NY 会话信息面板（简化版 tab2）
✅ NY/Asia/London 背景色带（bgcolor 替代）
🟡 时区/会话边界按 MT4 时间体系映射，不可能与 Pine 时区模型 100% 同步
❌ hr4Act / D1Act 活动度文本未完整复刻（仍为简化显示）
5) UT Bot
✅ ATR trailing stop + buy/sell 信号
✅ Heikin-Ashi 源切换
✅ label 管理（show / keep recent only / max labels）
🟡 Pine barcolor 与 alert 行为仅部分等价（MT4 指标端限制）
6) Hull Suite
✅ HMA / EHMA / THMA 模式
✅ 长度与乘数
✅ HTF 源开关（useHTF + htfMin）
✅ switchColor（按 HULL vs HULL[2] 变色）
🟡 Pine fill(Fi1,Fi2)、barcolor(candleCol) 无法 1:1（MT4 指标限制）
7) LuxAlgo FVG
✅ FVG 检测与框体
✅ 缓解（mitigation）
✅ 全量 + 增量更新
🟡 Pine 动态 FVG / table dashboard 属于简化替代，不是全等 UI
8) LuxAlgo Order Blocks
✅ 成交量枢轴 + os 方向逻辑
✅ Bull/Bear OB 生成、均价线、样式、数量控制
✅ Wick/Close 缓解逻辑
✅ 可见区重绘与对象管理
9) Three Bar Reversal
✅ Normal/Enhanced/All
✅ 趋势过滤（MA cloud / Supertrend / Donchian / None）
✅ SR level/zone 持续逻辑
10) Reversal Signals（RS）
✅ 动量相（Completed / Detailed / None）
✅ SR 水平（Momentum）
✅ Exhaustion 镜像相（含模式）
✅ Ex SR 扩展
✅ rsBRS / rsERS / ttERS / tsoRS / warRS 已给出并实现 MT4 语义版本
🟡 这几项在 Pine 原文件里仅 input 占位、非完整原逻辑，因此你现在是“合理补全版”
结论（量化）
已完成（可用）：约 85%~90%
近似完成（平台差异）：约 8%~12%
明确未完成：约 2%~5%

