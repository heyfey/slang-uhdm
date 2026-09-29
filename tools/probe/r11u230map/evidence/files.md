* **cluster_index.csv**: one row per cluster (695): rows (row-modes carrying it) with the surelog / uhdm2rtlil split,
  tests, objects, probe cases, first_in_rows, **ground** (decoded override, else the writer's file, else the mint's),
  coverage (COVERED by which live pair and why, or OPEN with its map-14 history), `rows_after_pairs`,
  `probe_after_pairs`, `first_in_after_pairs`, **`alone_on_top_of_pairs`** (row-modes it clears alone on top of both
  pairs), `alone_on_pristine`, the same against the NAMED heads only, map 14's rows, coverage and site (`map14_*`),
  families, example tests, **site** (the MINT: `mint < caller < caller` with the nearest law), **writer** (the
  WRITER of the differing field, section 5) and **writer_chain_grounds**, probe laws, key, example object.
* **clusters.csv**: row-mode x cluster with its object count and a `first` flag; **probe_clusters.csv** the same per
  case; **fail_list.csv** / **probe_fail_list.csv**: every STRICT_NOTEQUAL row-mode / case with its first cluster,
  coverage, ground, mint site, **writer**, counts, and whether the live pairs clear it (optimistic and named-only).
* **evidence/**: `report.txt` (drivers/report15.py, every table), `audit.txt` (drivers/audit15.py), `final15.txt`
  (the clustering run), `routes.json`, `ground_override.json`, `greedy15.json`, `greedy15_named.json`,
  `pristine_index.csv` (the id assignment against maps 1-14), `rowsets.txt` (drivers/rowsets.py), `objects.csv` (one
  example object per cluster), `sites.json` (this edition's 28 mint re-pins), `tables/` (drivers/tables15.py),
  `clusters/` (the record dumps of one example per cluster that has a row or at least 3 cases, drivers/evid.py),
  `writers/` (`sites_writer.json` and `writer_ground.json` from drivers/pwsum.py, the pass-225-off validation, the
  count of gdb runs `npw.txt`), `landings/` (drivers/landing15.py per landing, drivers/delta15.py against map 14),
  `sweeps/` (the pristine and landing-off gate sweep logs, byteverify, the probe comparison, the binary audit),
  `away/` (drivers/awayall.py per state, canonical and raw, and the reversed controls), `controls/`,
  `determinism/`, `rebuild/`, `uvm/` (census and distance), `downstream/` (the face list and verdicts),
  `addendum_9c9c11d6/`.
* **drivers/** (every path resolved from the checkout or from `MAP_W` / `MAP_BIN` / `MAP_H` / `SWPFX` / `SP` set by
  the caller; no scratch path is hard-coded; every driver that reads databases, sources or case lists reads the fence
  list itself and fails closed; every tool called through a variable is checked with `[ -x ]`): `env.sh`,
  `common.py` (the key rewrite and the fence), `jobs.py`, `probejobs.py`, `probelaw.py`, `strict_runs.sh`, `run1.sh`,
  `analyze.py` (map 13's analyzer, unchanged), `final15.py` (ids), `delta15.py`, `statejobs.py`, `landing15.py`,
  `statesweeps.sh`, `movers.sh`, `bvmirror.sh`, `probecmp.sh`, `awaylandings.sh`, `awayall.py`, `mkroutes15.py`,
  `mkroutes_add.py`, `report15.py`, `tables15.py`, `rowsets.py`, `audit15.py`, `evid.py`, `pinmulti.py` + `sites.py`
  (mint pins) with `objrank.cpp`, **`pinwriter.py` + `pwsum.py` (writer pins) with `fieldoff.cpp` / `ccw.sh`**,
  `addmerge.py` (the addendum), `controls.sh`, `det.sh`, `ob.sh`, `rebuildid.sh`, `dsfaces.py`, `uvmcensus9.sh` +
  `uvmcensus.py` + `uvmfamilies.py`, `uvmdist.sh`, `cc.sh` and `strictcmp_x.cpp` (map 13's variant comparator),
  `headtable.py` (the head-record writer table), `readme15.py` (fills README.src.md's generated tables into README.md),
  `run15.sh` (the order the pipeline ran in).
  No patch file is in this directory.
* **Fence**: a grep of this directory for the four fenced names reads 0; the gate sweeps dispatched every row as the
  gate mandates, and nothing else of this map ran on, dumped or read a fenced test's sources or databases.
* **Process**: the pinwriter's first part stalled on the slowest examples (BlackBePipeInt, Earlgrey_0_1) and was
  stopped by this map (its own process, after checking the command line) and its remaining 89 clusters re-run in three
  parts; its partial output is kept, a cluster's later pin replacing an earlier one. No tool was ever called through
  an unset variable. The scratch used for this map was about <<SCRATCH>> (sweeps, mirrors, record dumps, gdb runs),
  under 20 GB.
