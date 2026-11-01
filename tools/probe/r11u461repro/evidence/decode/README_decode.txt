Decode of uvm_use_models_pipelined_get_put's head at the base (64a77889, control /tmp/intr11u459 database):
uhdm-cmp 56 lines: golden param_assign#120499 (mbus_types_pkg DEFINITION view, Rhs $bits call) paired with
ours param_assign#183034 (mbus_types_pkg ELABORATED view, Rhs UINT:100).  UHDM Compare keeps a visited set
keyed on the golden object, so the pair is made where golden reaches the DEF package through a pointer that
in ours reaches the TOP package.  whopoints.cpp: the only pointers to golden's DEF types_pkg are vpiInstance
links (code 745).  Bisect over every TOP-instanced typespec of ours (blanket2.cpp, simulation on a copy of
the database, nothing in src): the culprit is ours #5660, the unparented logic_typespec base of the enum
mbus_resp_e copies (module top_tb's transitive copy and interface MBUS's enum_var copy share it), TOP in ours,
DEF in golden.  With it re-pointed the head becomes golden's design-level parameter MBUS_SEQ_ITEM_NUM_BITS
against ours' $bits call (the § unitImportHoistsPkgParams146 binding branch, UhdmExporter); with that branch
widened as well (rebind.cpp) the head becomes mbus_pipelined_check_seq::dummy_response's variable listing.
Both faces are the sister's ground (TypeEmit/UhdmExporter build the enum copy's base; UhdmExporter binds).
The importing package's param_assign typespec vpiInstance (golden: home DEF view; ours: TOP; simdef.cpp)
differs too but is invisible to uhdm-cmp on this row (the DEF package is visited first through AllPackages).
Cases: decode/EB (eb06-eb08 reproduce the shared enum base: STRICT_EQUAL on both binaries, invisible),
decode/RX (the importing-package param_assign instance), decode/PB (the $bits shapes).
