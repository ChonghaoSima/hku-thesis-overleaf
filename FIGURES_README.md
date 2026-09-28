# 修改论文图片 / 流程图：给 agent 的操作手册

本文件说明如何修改司马崇昊 HKU 博士论文 *Taming the Curse of Reality: Towards Robust Physical Agents from Perception to Action* 中的任何图片（TikZ 流程图或论文插图），并保证改完仍能编译、与正文一致、能同步到 Overleaf / GitHub / HDFS。

---

## 0. 直接复制给另一个 agent 的提示词

```text
你要修改一篇 HKU 博士论文（LaTeX，pdfLaTeX 编译）中的图片。
仓库：https://github.com/ChonghaoSima/hku-thesis-overleaf （公开仓库；主文件 main.tex）
开始前先完整阅读仓库根目录的 FIGURES_README.md，并严格按其中的流程操作：
1) 在第 3 节的图表清单里找到要改的图对应的源文件；
2) 按第 4、5 节的规范修改（流程图改 TikZ 源文件，插图替换 images/ 下的文件）；
3) 不得违反第 6 节列出的事实约束（章节对应、评测保真度、合作作品标注、数字）；
4) 按第 7 节编译并逐页渲染检查，确认 build ok、0 个未定义引用、0 个超宽行；
5) 按第 8 节提交；只改与图有关的文件，不要改导言区、类文件和其他章节正文。
我要改的是：<在这里写：图号 + 想要的修改>
```

---

## 1. 获取与同步

| 位置 | 说明 |
|---|---|
| GitHub | `https://github.com/ChonghaoSima/hku-thesis-overleaf`，分支 `main`，公开可 clone |
| Overleaf | 与 GitHub 仓库双向关联。Overleaf 里改完要点 **Menu → GitHub → Push Overleaf changes to GitHub**；GitHub 有新提交后要点 **Pull GitHub changes into Overleaf** 才能看到 |
| 作者开发机 | `/home/tiger/repos/hku_thesis`（同一仓库的本地副本） |
| HDFS 永久备份 | `/mnt/hdfs/harunawl/home/byte_data_seed_wl/vlm/iccv/user/smch/hku_thesis_hdfs/`（`latest/` 为最新镜像，`latest/thesis.pdf` 为最新 PDF） |

**同步守护进程**：作者开发机上每 30 分钟自动执行一次：编译 → 镜像到 HDFS → `git commit` → `git fetch` + `git rebase origin/main` → `git push`。因此：

- **在其他机器上改**：`git clone` 后修改，推送到 `main`（需要你自己对该仓库有写权限），或在 Overleaf 里改后 Push 到 GitHub。开发机会在下一轮同步时自动 rebase 进来。**不要和开发机同时改同一个文件**，否则 rebase 冲突时守护进程会停止推送（日志 `~/.cache/hku_thesis_sync/sync.log` 中出现 `CONFLICT`），需要人工解决。
- **在作者开发机上改**：直接在 `/home/tiger/repos/hku_thesis` 修改即可。改到一半不想被自动提交时，先 `tools/thesis_sync.sh stop`，改完再 `tools/thesis_sync.sh start`；随时可用 `tools/thesis_sync.sh status` 查看状态、`tools/thesis_sync.sh once` 立即同步一次。开发机访问 GitHub 走 `ssh.github.com:443` + 公司代理，已在仓库的 git 配置里设好，无需额外操作。开发机其他外网访问需先 `export http_proxy=http://sys-proxy-rd-relay.byted.org:8118 https_proxy=$http_proxy`。

---

## 2. 编译环境与命令

- **编译器**：pdfLaTeX + BibTeX（natbib，`unsrtnat` 样式），主文件 `main.tex`。Overleaf 上默认设置即可编译。
- **本地依赖**（Debian/Ubuntu）：`texlive-latex-extra texlive-pictures texlive-science texlive-fonts-extra texlive-bibtex-extra latexmk`；只有重新生成中文名图片时才需要 `texlive-xetex texlive-lang-chinese`。
- **全文编译**（在仓库根目录）：

  ```bash
  bash tools/build_thesis.sh
  # 期望输出：build: ok / undefined references: 0 / undefined citations: 0 / overfull hbox > 10pt: 0
  # PDF 在 build/main.pdf，日志在 build/main.log
  ```

- **单章快速编译**（改某一章的插图时更快）：

  ```bash
  bash tools/compile_chapter.sh occnet     # 可选：occnet | drivelm | centaur | kai0
  # PDF 在 build/chapters/<key>/test_<key>.pdf；其他章节的交叉引用会显示为 ??，属正常
  ```

  流程图所在的第 1、3、8 章没有单章脚本，用全文编译。

---

## 3. 图表清单（图号 → 源文件）

图号以 `build/main.pdf` 为准。标签（label）在正文中用 `Fig.~\ref{标签}` 引用。

### 3.1 TikZ 流程图（可直接改源码）

| 图号 | 标签 | 源文件 | 内容 |
|---|---|---|---|
| 1.1 | `fig:intro:overview` | `ch-introduction/figures/thesis_overview.tex` | 论文总览：现实世界 → 感知/推理/行动三栏（RQ1–3，第 4–7 章）→ RQ4 架构带 → 第 2/3/9 章 |
| 3.1 | `fig:method:shift` | `ch-methodology/figures/shift_taxonomy.tex` | 四类偏移（感知/语义/行为/部署）→ 部署时症状 → 方法论杠杆 → 对应章节 |
| 3.2 | `fig:method:cycle` | `ch-methodology/figures/research_cycle.tex` | benchmark-driven 研究循环六阶段，中心为 curse of reality，灰字为各阶段的代表作品 |
| 3.3 | `fig:method:lineage` | `ch-methodology/figures/lineage.tex` | 18 篇论文谱系：横轴年份，纵向四条泳道（Perceive/Reason/Act/Architecture）+ 早期工作行；实线=基于，虚线=启发/对比 |
| 3.4 | `fig:method:ladder` | `ch-methodology/figures/evaluation_ladder.tex` | 评测保真度阶梯 L0–L3 及各章所处层级 |
| 3.5 | `fig:method:decision` | `ch-methodology/figures/lever_decision.tex` | 从现场失败到研究贡献的决策流程（6 个问题 → 6 个杠杆 → 评测与开放） |
| 4.8 | `occnet:fig:openscene_usage` | `ch-occnet/occnet.tex` 中内联的 `tikzpicture`（约第 397 行） | OpenScene 与其下游用途 |
| 8.1 | `fig:disc:anatomy` | `ch-discussion/figures/self_correcting.tex` | 自我纠错物理智能体的结构（表示/慢推理/快行动 + 能力监控 + 学习回路） |

这些图在正文中通过 `\tikzfig[宽度]{路径}` 插入，例如 `ch-methodology/methodology.tex` 中的 `\tikzfig{ch-methodology/figures/research_cycle}`。

### 3.2 论文插图（PDF/JPG/PNG，来自已发表论文）

没有可编辑的原始工程文件（PPT/AI/Figma 等不在仓库里）。要修改只能：用同名文件替换，或放入新文件并修改 `\includegraphics` 路径。

| 章 | 图号：标签 → 文件（均在该章的 `images/` 目录下） |
|---|---|
| 第 4 章 OccNet（`ch-occnet/occnet.tex`） | 4.1 `occnet:fig:motivation` → `fig_motivation_v7_used.pdf`；4.2 `occnet:fig:framework` → `fig_pipeline_overview_v8_used.pdf`；4.3 `occnet:fig:compare_gt` → `fig_compare_dataset_used.jpg`；4.4 `occnet:fig:compare_occ_method` → `fig_occ_gt_pred_used.jpg`；4.5 `occnet:fig:pretrain_for_detection` → `fig_compare_pretrain_v2_used.pdf`；4.6 `occnet:fig:planning` → `fig_planning_used.jpg`；4.7 `occnet:fig:irregular` → `fig_irregular_object_used.jpg` |
| 第 5 章 DriveLM（`ch-drivelm/drivelm.tex`） | 5.1 `drivelm:fig:teaser` → `teaser_smch_v10.pdf`；5.2 `drivelm:fig:data_collection` → `data_v8_1_smch.pdf`；5.3 `drivelm:fig:model_pipeline` → `model_pipeline_smch_v1.pdf`；5.4 `drivelm:fig:qualitative` → `qualitative_smch_v7.pdf` |
| 第 6 章 Centaur（`ch-centaur/centaur.tex`） | 6.1 `centaur:fig:teaser` → `main_fig_v15.pdf`；6.2 `centaur:fig:pipeline` → `pipeline_v11.pdf`；6.3 `centaur:fig:navsafe` → `navsafe_v12.pdf`；6.4 `centaur:fig:vis` → `vis_v7.pdf` |
| 第 7 章 χ0（`ch-kai0/kai0.tex`） | 7.1 `kai0:fig:teaser` → `kai0_teaser_v5_4_compress.pdf`；7.2 `kai0:fig:pipeline` → `pipeline_v6_compress.pdf`；7.3 `kai0:fig:arithmetic` → `arithmetic_v4.pdf`；7.4 `kai0:fig:advantage` → `advantage_v4_1_compress.pdf`；7.5 `kai0:fig:consistency` → `consistency_v4.pdf`；7.6 `kai0:fig:robot_setup` → `setup_v3_compress.pdf`；7.7 `kai0:fig:exp_triple` → `triple_compress.pdf`（表 7.2 的 Task A 数值读自此图）；7.8 `kai0:fig:exp_souping` → `souping_compress.pdf`；7.9 `kai0:fig:exp_advantage` → `advantageA_B_compress.pdf`；7.10 `kai0:fig:exp_dagger_a` → `dagger_ff_compress.pdf`；7.11 `kai0:fig:exp_dagger_c` → `dagger_demoB_compress.pdf`；7.12 `kai0:fig:exp_aug_control` → `aug_control_compress.pdf` |
| 附录 A（`ch-occnet/occnet_appendix.tex`） | A.1 `occnet:fig:occ_gt_pipeline` → `fig_occ_gt_pipeline_used.jpg`；A.2 `occnet:fig:statistics_occ` → `fig_occ_label_distribution_used.jpg`；A.3 `occnet:fig:statistics_flow` → `fig_flow_distribution_used.pdf`；A.4 `occnet:fig:planning2` → `fig_planning2_used.jpg`；A.5 `occnet:fig:occ_pred` → `fig_occ_vis_1_used.jpg` |
| 附录 B（`ch-drivelm/drivelm_appendix.tex`） | B.1 `drivelm:fig:composition` → `nus_data_supp_v2.pdf`；B.2 `drivelm:fig:nus_anno_pipeline` → `nus_pipeline_supp_v2.pdf`；B.3 `drivelm:fig:data_distribution` → `data_v8_2_smch.pdf`；B.4 `drivelm:fig:nus_statis` → `nus_stats_supp.pdf`；B.5 `drivelm:fig:nus_obj_stats` → `nus_objstats_supp.pdf`；B.6 `drivelm:fig:carla_graph` → `carla_graph.pdf`；B.7 `drivelm:fig:simple_pipeline` → `rebuttal_simple_pipeline.jpg`（实为 PNG 格式，文件名保留） |
| 附录 C（`ch-centaur/centaur_appendix.tex`） | C.1 `centaur:fig:vis_group` → `group12.pdf` |
| 附录 D（`ch-kai0/kai0_appendix.tex`） | D.1 `kai0:fig:failure_case` → `failure_case_trim.pdf`；D.2 `kai0:fig:loss_curve_sa` → `loss_curve_SA.jpeg`；D.3 `kai0:fig:app_soup_a` → `souping_ff_compress.pdf` + `souping_demoA_compress.pdf`；D.4 `kai0:fig:app_sa_c` → `advantage_demoB_compress.pdf`；D.5–D.7 `kai0:fig:app_tda_{a,b,c}_abs` → `{ff,demoA,demoB}_{abs,delta}_compress.pdf` |

### 3.3 前置页图片

| 文件 | 用途 | 修改方式 |
|---|---|---|
| `Classes_final/HKUcolour.pdf` | 封面 HKU 校徽 | 一般不改 |
| `Classes_final/name_sima.pdf` | 封面中文名「司马崇昊」 | 用 XeLaTeX 重新生成：`\documentclass[border=0.5pt]{standalone}\usepackage[fontset=fandol]{ctex}\begin{document}\songti 司马崇昊\end{document}`，编译后覆盖该文件 |

**查找任意图**：`grep -rn "标签名" --include=*.tex .` 或 `grep -rn "文件名" --include=*.tex .`。

---

## 4. 改 TikZ 流程图的规范

1. **只改 `figures/*.tex` 里的 `tikzpicture`**（第 4.8 图例外，它内联在 `ch-occnet/occnet.tex`）。图注（caption）和标签在引用它的章节文件里，内容变化时要同步改图注。
2. **插入方式必须用 `\tikzfig[宽度]{路径}`**（定义在 `thesis_macros.tex`）。它会把图按单倍行距排版并缩放到给定宽度（默认 `\textwidth`，约 15.4 cm）。正文是 1.5 倍行距（`\linespread{1.5}`），直接 `\input` TikZ 会让节点文字行距变大、互相重叠。
3. **字号**：文档是 12pt，`\scriptsize` = 8pt、`\tiny` = 6pt，比 10pt 文档大约 15%。画布宽度建议 13–18 cm，由 `\tikzfig` 缩放；画布越宽，最终字越小，缩放后有效字号不要低于约 6pt。节点文字放不下时，优先加宽 `text width` 或画布，而不是缩小字号。
4. **颜色**（`thesis_macros.tex` 中定义，全篇统一）：`perceive`（蓝，感知）、`reason`（橙，推理）、`act`（绿，行动）、`arch`（紫，架构）、`bench`（灰蓝，基准/数据）、`reality`（红，现实世界）、`lightgray`、`earlier`、`legendgray`。
   - 样式会在颜色后追加混色（如 `fill=#1!12`），所以**不要把 `black!60` 这类混合色直接传给样式**，会报 `Undefined color`。先 `\colorlet{新名字}{black!60}` 再使用。
5. **可用的共享样式**：`box`、`pillar=颜色`、`stage=颜色`、`paper=颜色`、`firstauthor=颜色`、`benchmark`（虚线框）、`flow`（主箭头）、`dep`（细箭头）、`note`、`lane=颜色`、`decision`（菱形判断框）。已加载的库：`positioning, arrows.meta, shapes.geometric, shapes.misc, calc, fit, backgrounds, decorations.pathreplacing, decorations.pathmorphing`；另有 `pgfplots`（`compat=1.18`）。
6. **章节号不要写死**：节点里用 `Chapter~\ref{ch:occnet}` 这类引用。各章标签为 `ch:intro, ch:background, ch:methodology, ch:occnet, ch:drivelm, ch:centaur, ch:kai0, ch:discussion, ch:conclusion`，附录为 `app:occnet, app:drivelm, app:centaur, app:kai0`。
7. **合作作品标注**：凡图中出现作者参与但非主导的工作，名称后加 `$^{*}$`，并在图注中说明（现有图注写法：“Works marked $^{*}$ are co-authored rather than led by the author.”）。

---

## 5. 替换论文插图的规范

1. 文件放在对应章节的 `images/` 目录，`\includegraphics` 路径从仓库根目录写起，例如 `\includegraphics[width=\linewidth]{ch-centaur/images/pipeline_v11.pdf}`。
2. **格式**：优先矢量 PDF；照片或截图用 JPEG（质量约 92），线条图用 PNG。pdfLaTeX 不支持 EPS，需要先用 `epstopdf` 转成 PDF。
3. **大小**：单个文件尽量小于 2–3 MB，否则 Overleaf 编译变慢甚至超时。带透明通道的 PNG 转 JPEG 时要先铺白底，否则透明区域会变黑（Python：`Image.alpha_composite(Image.new("RGBA", im.size, "white"), im.convert("RGBA")).convert("RGB")`）。
4. 同名替换最省事；若改文件名，必须同步修改所有引用它的 `\includegraphics`，并删除不再使用的旧文件。
5. 宽度用 `\linewidth` / `\textwidth` 的比例，浮动位置用 `[t]` 或 `[tb]`。

---

## 6. 改图时不能违反的事实（与正文保持一致）

- **章节对应**：第 4 章 感知（OccNet、OpenOcc、OpenScene）；第 5 章 推理（DriveLM）；第 6 章 行动 I（Centaur，驾驶）；第 7 章 行动 II（χ0，机械臂操作）；第 8 章 讨论（RQ4 为综合与研究议程，**不是**已实现的系统）；第 2 章 文献综述；第 3 章 研究方法论；第 9 章 结论。
- **四类偏移 ↔ 杠杆 ↔ 章节**：感知偏移 → 通用 3D 表示（第 4 章）；语义偏移 → 结构化推理（第 5 章）；行为偏移 → 测试时自我纠错（第 6 章）；部署偏移 → 训练-部署对齐（第 7 章）。另有两个贯穿性杠杆：数据（扩规模或精选，以合作作品 AgiBot World 为例）和测量（基准）。
- **评测保真度**：第 4、5 章为 L0（开环，离线数据）；第 6 章为 L1（NAVSIM 非反应式仿真）；第 7 章为 L3（真机）；**L2 闭环仿真没有用于任何学习型智能体**（仅用于验证 PDM-Lite 专家）。论文中没有任何驾驶结果在实车上验证。
- **监控信号**：Cluster Entropy 是无标签的（第 6 章）；Stage Advantage 需要人工阶段标注，属于有监督信号，且只用于训练（第 7 章）。
- **合作作品（图中需加 `$^{*}$`）**：UniAD、BEVFormer、ETA、AgiBot World、OpenLane-V2、DriveBench、Hint-AD、SDF、VCD、BEV survey 的挑战赛团队成绩（Waymo 2022）、self-directed learning 观点论文。作者主导的（不加星号）：OccNet/OpenOcc、OpenScene、DriveLM、Centaur、χ0、PersFormer/OpenLane（共同一作）、BEV survey（共同一作）、LSH-SMILE。
- **数字只能取自正文**，例如：Centaur 在 NAVSIM 上 90.3 → 92.6（单次运行），三种子 92.10 ± 0.33；navsafe 74.14 对比人类 94.65；χ0 在 Task A 上成功率约 27% → 约 97%（30 次试验，读自图 7.7）；OpenOcc 34,149 帧、超过 14 亿体素；DriveLM 挑战赛 152 支队伍。不确定的数字不要画进图里。

---

## 7. 编译与检查清单

```bash
cd <仓库根目录>
bash tools/build_thesis.sh
```

1. 必须看到 `build: ok`、`undefined references: 0`、`undefined citations: 0`、`overfull hbox > 10pt: 0`。报错时看 `build/main.log` 中以 `!` 开头的行。
2. **逐页渲染目视检查**：先用逐页文本定位图所在的页，再渲染该页：

   ```bash
   for p in $(seq 1 320); do pdftotext -f $p -l $p build/main.pdf - 2>/dev/null | grep -q "图注里的一个短语" && echo $p; done
   pdftoppm -r 80 -png -f <页码> -l <页码> build/main.pdf /tmp/check
   ```

   注意：**不要**用 `pdftotext` 输出整篇再按换页符 `\f` 切分来算页码，这样会错位约 6 页。
3. 检查项：文字不溢出框、框与框不重叠、箭头不穿过其他框、缩放后文字清晰、配色与全篇一致、图注与图内容一致。
4. 若改了图注或标签，确认 List of Figures（目录后的图目录）里的短图注（`\caption[短图注]{长图注}`）同步更新。

---

## 8. 提交

- 只提交与图有关的改动（`figures/*.tex`、`images/*`、以及对应章节中的图注），提交信息写清楚改了哪张图，例如：`Revise Fig. 3.3 (lineage): move ETA to Architecture lane`。
- 在其他机器：`git add -A && git commit -m "..." && git push origin main`（需要写权限）；或在 Overleaf 修改后 Push 到 GitHub。
- 在作者开发机：提交后可等待守护进程下一轮自动推送，或执行 `tools/thesis_sync.sh once` 立即同步（同时更新 HDFS 上的 PDF）。
- 不要修改：`Classes_final/`、`Preamble_final/`、`thesis_macros.tex` 中已有的颜色和样式定义（可以新增）、`references.bib`、各章正文（除图注外）、`tools/`。确有必要时，先在提交说明里写明原因。
