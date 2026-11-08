# v3 图表交接说明（给负责编译与替换的 agent）

## 0. 作者已选定的版本（2026-11-08）

| 论文图号 | 选用 | 要替换进正文的文件 |
|---|---|---|
| Fig. 1.1 | **v3** | `ch-introduction/figures/thesis_overview_v3.{pptx,pdf}` |
| Fig. 1.2 | **v3** | `ch-methodology/figures/lineage_v3.{pptx,pdf}` |
| Fig. 2.8 | **v3** | `ch-occnet/figures/openscene_usage_v3.{pptx,pdf}` |
| Fig. 6.1 | **v4 闭环环形版**（不是 v3） | `ch-discussion/figures/self_correcting_v4.{pptx,pdf}`，15.38 × 7.23 cm |

对应的一键替换（方式 A，旧文件改名为 `_v2` 保留）：

```bash
cd hku-thesis-overleaf
for f in ch-introduction/figures/thesis_overview ch-methodology/figures/lineage ch-occnet/figures/openscene_usage; do
  for ext in pdf pptx; do mv "$f.$ext" "${f}_v2.$ext" && mv "${f}_v3.$ext" "$f.$ext"; done
done
f=ch-discussion/figures/self_correcting
for ext in pdf pptx; do mv "$f.$ext" "${f}_v2.$ext" && mv "${f}_v4.$ext" "$f.$ext"; done
```

Fig. 6.1 选了 v4，图注建议改为（conclusion.tex:39）："Proposed anatomy of a self-correcting physical agent, drawn as the perceive--reason--act loop closed through the deployment world. Numbers 1--5 are the elements graded in Table~\ref{tab:disc:evidence}; L0--L3 give the evaluation fidelity of the supporting evidence; the dashed arc is the direct fast path taken when the competence monitor is confident, and the learning loop updates policies and benchmarks between deployments ($^{*}$ denotes co-authored works)." 其余三张图的图注要求见第 3 节（Fig. 1.2 的 18/20 胶囊数必须改）。未选用的 `thesis_overview_v4a/v4b` 与 `self_correcting_v3` 保留在目录中作为备份，不要插入正文。

日期：2026-11-03。本次只优化了当前 6 章版论文**实际引用**的 4 张本论文自制 PPT 图。新版本一律以 `_v3` 后缀放在原图旁边，**没有覆盖任何现有文件，也没有改任何 `.tex`**。替换、编译、改图注由你完成。

## 1. 文件位置与对应关系

| 论文图号 | 标签 | 正文引用（未改） | 新文件（同目录，`_v3`） | 插入宽度 |
|---|---|---|---|---|
| Fig. 1.1 | `fig:intro:overview` | `ch-introduction/introduction.tex:31` → `ch-introduction/figures/thesis_overview.pdf` | `ch-introduction/figures/thesis_overview_v3.{pptx,pdf}` | `\textwidth`；PDF 15.38 × 7.76 cm（v2 为 7.3 cm 高） |
| Fig. 1.2 | `fig:method:lineage` | `ch-introduction/introduction.tex:48` → `ch-methodology/figures/lineage.pdf` | `ch-methodology/figures/lineage_v3.{pptx,pdf}` | `\textwidth`；PDF 15.38 × 10.51 cm（v2 为 9.89 cm 高，**高了 0.6 cm，注意第 6 页排版**） |
| Fig. 2.8 | `occnet:fig:openscene_usage` | `ch-occnet/occnet.tex:392` → `ch-occnet/figures/openscene_usage.pdf` | `ch-occnet/figures/openscene_usage_v3.{pptx,pdf}` | `\linewidth`；PDF 已按 15.38 cm 画，不再被放大（v2 为 14.44 cm 宽，曾被放大 6%） |
| Fig. 6.1 | `fig:disc:anatomy` | `ch-conclusion/conclusion.tex:38` → `ch-discussion/figures/self_correcting.pdf` | `ch-discussion/figures/self_correcting_v3.{pptx,pdf}` | `\textwidth`；PDF 15.38 × 7.23 cm（v2 为 6.46 cm 高） |

同一套文件也在包目录 `ppt_figures/` 下：`fig*-*_v3.pptx`、`pdf/*_v3.pdf`、`png/*_v3.png`（300 dpi），生成脚本在 `ppt_figures/_generator/fig_*_v3.py`（共用 `v3style.py`）。v2 与 v3 的上下对比图在 `ppt_figures/v3_review/compare_*_v2_vs_v3.png`，先看这四张再替换。

`ch-methodology/figures/` 里原 Fig. 3.1/3.2/3.4/3.5（shift taxonomy、research cycle、evaluation ladder、lever decision）已不被 `main.tex` 引用，这次**没有**重做；它们仍写着旧的 Ch. 4–7 编号，不要再插回正文。

## 2. 替换方式（二选一）

方式 A（推荐，保持 `.tex` 不动，符合 FIGURES_README 的"同名替换"规范）：

```bash
cd hku-thesis-overleaf
for f in ch-introduction/figures/thesis_overview ch-methodology/figures/lineage ch-occnet/figures/openscene_usage ch-discussion/figures/self_correcting; do
  for ext in pdf pptx; do mv "$f.$ext" "${f}_v2.$ext" && mv "${f}_v3.$ext" "$f.$ext"; done
done
```

方式 B：把 4 处 `\includegraphics{...}` 的路径改成 `*_v3.pdf`，旧文件保留。

## 3. 每张图改了什么（审稿意见来源见括号）

**Fig. 1.1 总览**
- 三个阶段标题右侧加 `RQ1 / RQ2 / RQ3` 白色标签，与图注和下文的 RQ 列表一致（原图只有 RQ4）。
- Stage 2 第二张子卡改为原生矢量的 Graph VQA 示意：三层问答节点 P1 → P2 → P3 再到 B（behaviour）、M（motion），全部用 Reason 的橙色渐变；v2 用的是光栅图，右侧药丸还混用了感知蓝/行动绿。
- 子图略放大（1.80 × 1.15 cm），子卡边框淡化；图片标签改句首大写（Rigid 3D box、Key objects、w/o TTT (crash) 等）。
- 底部紫色带改为按第 6 章 Table 6.1 顺序列出自纠错智能体的五个要素 (1)–(5)，合作作品仍带 `*`（M3 审稿曾指出原带子把 PerturBot* 当成"design lesson"）。
- 图注可不改；若想呼应，可在图注末尾加一句 "(1)–(5) are the five architectural elements graded in Table 6.1"。

**Fig. 1.2 研究谱系**
- 泳道标题改为两行并写明对应章节：Architecture / Chapter 6，Act / Chapters 4–5，Reason / Chapter 3，Perceive / Chapter 2。胶囊加宽到 1.70 cm，名称 7 pt、venue 7 pt（v2 为 6.5 pt，S3/M3 审稿均提到字太小），整图不再有小于 7 pt 的文字。
- 图例改为 "core-chapter work led by the author"（M3、委员 B：原 "led by the author" 与图注"五篇核心章节工作"不一致）。
- χ0 加 ■（第 5 章末尾写明 datasets 与代码已公开发布）。
- venue 补全/更正：OccNet 胶囊第三行 ICCV’23，PersFormer 胶囊第三行 ECCV’22，Self-directed learning → CVPRW’26（委员 A t6），FLARE / PerturBot → arXiv’26，BEV Survey → T-PAMI’24（与参考文献年份一致，仍放 2023 列）。
- 箭头语义按正文核对后调整（**请作者确认**）：
  - DriveLM → Centaur 实线保留，标注改为 "5 steering bins"（centaur.tex:20、:82 写明 Cluster Entropy 复用 DriveLM 的五个横向转向类别；原标注 "anchors" 含义不清）。
  - UniAD → DriveLM 由实线改虚线（drivelm.tex:25 把 DriveLM 与 UniAD 作为对比而非继承）。
  - 新增 DriveLM ⇢ ETA 虚线（conclusion.tex:69：DriveLM 0.16 FPS 的慢推理动机了 ETA 的快慢双系统）。
  - 原 Self-directed learning → χ0 实线改为 χ0 ⇢ Self-directed learning 虚线（conclusion.tex:78：χ0 依赖人工恢复数据，这正是 self-directed learning 文章的出发点）。
  - 原 AgiBot World ⇢ PerturBot 虚线删除（正文无依据），改为 χ0 ⇢ PerturBot 虚线（kai0.tex:51："complementary co-authored work"）。
  - DriveBench 从 2025 第一列移到第二列，ETA 在其上方，Centaur 单独占 2025 第一列，从而没有任何箭头穿过或擦过胶囊（脚本内有自动间距检查，v2 的 DriveLM → Centaur 曾擦过 DriveBench 左上角）。
- **图注必须改**：现在的图注说 "the 18 capsules represent the 20 outputs"，但图里（v2 与 v3 都）是 20 个胶囊，与 Section 1.4 的 20 篇一一对应。建议改为："The 20 capsules correspond one-to-one to the 20 publications in Section~\ref{sec:intro:publications}; two capsules (\textsf{PersFormer + OpenLane} and \textsf{OccNet + OpenOcc}) each pair a method with the benchmark released in the same paper." 其余描述（实线/虚线/深色外框/方块）仍然成立；可补一句 "Lane titles give the chapters that cover each pillar."
- 两处由作者定夺、这次保持 v2 原状的标记：Centaur 没有 ■（第 4 章称 navsafe 为 "internal ... diagnostic subset"，不算公开发布）；PerturBot 保留 v2 的 ■（正文只说它提供 GroundFscore 诊断并开源，若不算 benchmark 就去掉）。ETA 仍只有入边、无出边（M3 说答辩时可能被问 ETA 与 FLARE 的关系，正文没有写明，所以没画）。

**Fig. 2.8 OpenScene 用途**
- nuPlan → OpenScene 箭头上下标注转换内容："2 Hz subsampling" / "+ occupancy & flow"；三条下游箭头各带一个说明芯片："occupancy & flow labels"（占据预测）、"sensor logs + splits"（端到端驾驶）、"sensor logs"（世界模型），即图注里"NAVSIM 和端到端赛道只用传感器日志、不用体素标注"的说明现在画在图里（M3 意见）。
- 端到端赛道卡片改为 "CVPR 2024: NAVSIM v1 (PDMS) / CVPR 2025: NAVSIM v2"，占据赛道卡片写明 "OpenScene occupancy track, mIoU; OccNet (ResNet50) baseline"（occnet.tex:366）。
- 数字与 v2 相同（1,521 logs、120+ h、four cities、>20 TB、2 Hz、~2 TB、8 cameras + LiDAR、0.5 m voxels）。
- 未动：世界模型卡片仍只写 CVPR 2024。occnet.tex:366 和 :583 的写法可读成"两条赛道都在 2024 和 2025 办过"，是否如此请作者确认后统一正文或图。

**Fig. 6.1 自纠错智能体**
- 五个要素按 Table 6.1 和 6.2 节段落编号：① Perceive 卡、② Reason (slow) 卡、③ Competence monitor 带、④ 标在 "adapt at test time" 箭头旁、⑤ Learning loop 带。
- 三个模块标题右侧加证据保真度芯片 L0 / L0 / L1 · L3（与图注 "L0/L1 driving evaluations or ... L3 robot trials" 对应）。
- monitor 行拆成两张卡：Cluster Entropy（Ch. 4 · L1，label-free，在线使用）与 Stage Advantage（Ch. 5 · L3，有监督，仅训练时使用）；learning loop 行拆成三张卡：Recovery data（Ch. 5 · L3）、Benchmark iterations（Ch. 1–3：OpenOcc → OpenScene → NAVSIM；DriveLM → DriveBench）、Self-direction（hypothesised：PerturBot*、self-directed goals and skills*）。事实均取自 conclusion.tex:36–80 与 Table 6.1。
- "BEV*" 改为 "BEVFormer*"（M3 意见），图注里的 "(BEV refers to BEVFormer)" 可删。
- 建议图注加一句说明编号与虚线："Numbers 1–5 are the elements graded in Table~\ref{tab:disc:evidence}; the dashed arc is the direct fast path taken when the monitor is confident."（M3 指出图注没提虚线路径）。

## 4. 替换后的检查

```bash
bash tools/build_thesis.sh      # 期望 build: ok / undefined references: 0 / undefined citations: 0 / overfull hbox > 10pt: 0
```

然后按 FIGURES_README 第 7 节逐页渲染检查这四页（当前 PDF 中分别是第 34、36、69、182 页，替换后可能移动）：Fig. 1.2 比 v2 高 0.6 cm，确认第 6 页上图注与 1.2 节标题仍在同页且无溢出；Fig. 6.1 比 v2 高 0.8 cm，确认第 152 页的 Table 6.1 浮动位置没有被挤到下一页太远。改过图注后核对 List of Figures。

## 4b. 备选版本（2026-11-08 新增，供挑选；默认推荐仍是 v3）

| 文件 | 风格 | 与 v3 的差别 | 尺寸 |
|---|---|---|---|
| `ch-introduction/figures/thesis_overview_v4a.{pptx,pdf}` | Fig. 1.1 纯文字卡片版 | 不放任何论文截图；每阶段两张作品卡（◆ 方法 / ■ 数据或基准）、一行描述（数字均取自正文：34,149 帧、>1.4 B 体素、152 支队伍、90.3 → 92.6 PDMS、Task A ≈27% → ≈97%）、底部评测保真度芯片（L0 / L0 / L1 · L3）和 ◆ ■ * 图例。最克制、最像常见博士论文总览图。 | 15.38 × 7.90 cm |
| `ch-introduction/figures/thesis_overview_v4b.{pptx,pdf}` | Fig. 1.1 按章节四卡片版 | 三个阶段标题下方是四张等宽章节卡（Ch. 2 / 3 / 4 / 5），Stage 3 标题横跨 Ch. 4 与 Ch. 5，一章一张图（箱体→占据对比、DriveLM 场景 + P1→P2→P3→B→M 链、Centaur w/o TTT → with TTT、χ0 三步）加两行说明。章节与卡片一一对应，比 v3 稀疏。 | 15.38 × 7.69 cm |
| `ch-discussion/figures/self_correcting_v4.{pptx,pdf}` | Fig. 6.1 闭环环形版 | 把感知–推理–行动画成一个环：部署世界在上，Perceive 左、Reason (slow) 下、Act (fast) 右，环上四段箭头为 observations / what is where / what matters / actions；③ 能力监控居中并向三个模块发出 re-perceive / invoke slow reasoning / ④ adapt online；虚线"direct path when confident"跨过监控器上方；⑤ 学习回路在环下方，以虚线在部署之间回灌 Perceive 与 Act。内容、编号与保真度芯片与 v3 相同。 | 15.38 × 7.37 cm |

对比图：`ppt_figures/v3_review/compare_fig1-1_thesis_overview_v3_v4a_v4b.png`、`compare_fig8-1_self_correcting_v3_v4.png`。若选用 v4a/v4b，Fig. 1.1 图注无需改（RQ 标签与五要素同 v3）；若选用 Fig. 6.1 的 v4，建议图注补一句 "the loop is closed through the deployment world; the learning loop updates policies and benchmarks between deployments"。替换方式同第 2 节，只需把 `_v3` 换成相应后缀。

## 5. 重新生成

```bash
cd ppt_figures/_generator
../../_scratch/venv/bin/python build.py v3        # 生成四个 _v3.pptx 并检查每个文本框是否放得下
../../_scratch/venv/bin/python build.py v4        # 三个备选版本（v4a、v4b、self_correcting_v4）
../../_scratch/venv/bin/python export.py fig1-1_thesis_overview_v3 fig3-3_lineage_v3 fig4-8_openscene_usage_v3 fig8-1_self_correcting_v3   # 本机 PowerPoint 导出 PDF + PNG
```

字体、配色、≥ 7 pt 规则与 FIGURES_README 第 4 节一致；章节号仍写死在图里（现为 Ch. 2–6）。替换完成后请把 `FIGURES_README.md` 第 3.1 节的图号表改成 6 章编号（1.1、1.2、2.8、6.1），并把四张未使用的方法论图标为已弃用。
