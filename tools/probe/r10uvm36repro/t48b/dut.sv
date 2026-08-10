// t48b — pass 36, cell B: the ENUM-ALIAS spelling of the same question.
//
// SeqDriver's 3 remaining `UVM_SEQ_ARB_TYPE` rows come from
//   typedef enum { ... } uvm_sequencer_arb_mode;      // uvm_object_globals
//   typedef uvm_sequencer_arb_mode UVM_SEQ_ARB_TYPE;  // backward compat
// i.e. an ALIAS OF AN ALIAS, which LAW S deliberately excludes from taking a
// per-declaration copy ("golden binds ONE shared `p::at` object everywhere").
// Golden on SeqDriver says that exception holds only for the HOME bodies:
//
//   DEFPKG uvm_pkg::uvm_sequencer_base::set_arbitration io0
//       enum_typespec 'uvm_pkg::UVM_SEQ_ARB_TYPE' @adpcm_pkg   (shared, LAST importer)
//   DEFPKG adpcm_pkg::uvm_sequencer_base::set_arbitration io0
//       enum_typespec 'UVM_SEQ_ARB_TYPE'          @uvm_pkg     (BARE, HOME)
//   ELABPKG adpcm_pkg::... same as the DEFPKG clone row
//
// so the import CLONE body still gets its own bare copy, instanced at the
// home — the § importCloneBareTdAlias16 + § lawSCopyHomeInstance36 pair, one
// typespec kind over.  `ae48_t` is the alias-of-alias; `de48_t` is a DIRECT
// enum typedef beside it, to separate "enum" from "alias of alias".
// Two importers, anti-sorted (`zz49` first, `aa49` second).

package home49;
  typedef enum { E48_A, E48_B } de48_t;
  typedef de48_t ae48_t;                 // alias of an alias
  function automatic int use_ae48(ae48_t v);
    return int'(v);
  endfunction
  function automatic int use_de48(de48_t v);
    return int'(v);
  endfunction
endpackage

// declared FIRST, sorts LAST
package zz49;
  import home49::*;
  function automatic int z49(ae48_t v);
    return use_ae48(v);
  endfunction
endpackage

// declared SECOND, sorts FIRST
package aa49;
  import home49::*;
  function automatic int a49(ae48_t v);
    return use_ae48(v);
  endfunction
endpackage

module mm49;
  import home49::*;
  ae48_t s49;
  initial s49 = E48_A;
endmodule
