# r10gapinv — the FULL GAP INVENTORY: every differing dump line in every remaining test, clustered

**Why this exists.** The user asked the right question: a cmp HEAD is only the
first brick the referee trips on — it says nothing about how much is stacked
behind it. This instrument answers "how far" properly: census BOTH dumps of
every remaining not-equal test, attribute every line to its OWNING OBJECT KIND
(own-child depth, names/ids/spans stripped), and diff the multisets — so every
instance of one law collapses into one FAMILY, aggregated across tests.

    usage: python3 gap_inventory.py     # reads /tmp/f57_wd_sl (a full surelog
           sweep workdir at the commit under study) + the golden cache

**The 266d3a6 reading (inventory-266d3a6.txt): 1037 families, 635,587 differing
instances, 80% in the top 111 families.** The top clusters, correlated
line-families merged by eye into object populations:

  ~120k  CONSTANT objects with their RANGE parents — all 9 tests, BOTH signs
         (we under-emit on SeqDriver/Earlgrey/UVM, OVER-emit on YosysVerx)
  ~80k   REF_TYPESPEC chains (vpiActual/vpiParent/vpiFullName + the
         int/bit/struct typespec pairs) — the known typespec-linkage cluster
  ~28k   HIER_PATH typespec/expr attachment — EARLGREY ONLY
  ~16k   REF_OBJ naming — NEGATIVE sign on Earlgrey/YosysVerx (we over/mis-name)
  ~5k    vpiSigned @int_typespec — both signs still live

**THE CAVEAT THE INVENTORY ITSELF PROVES: dump-gap count is NOT conversion
distance.** Earlgrey_0_1 carries ~50k instances here yet its uhdm-cmp output is
228 lines with ONE head — most of this table is invisible to Compare
(vpiFullName, vpiFile, parent edges, unreached objects) and is therefore
PHASE-3 (byte identity) work. Read this as: phase-2 distance = the per-test
head stacks (small, enumerable a few ahead); phase-3 distance = this map.
A family is an UPPER-bound clustering: one family can hide two laws, and
masking means a few gaps only appear after upstream fixes reshape the tree.

**How to use at slot-refill time:** prefer heads whose family also appears here
with a large multi-test footprint — the fix then pays several times. Re-run
after each landing wave; keep one inventory per base commit beside this README.
