// r10uvm47 arm t65a — the vpiActual BINDING of a PACKAGE VARIABLE's INITIALISER.
//
// The measured head (SeqDriver/SimpleUVM/Scoreboard, all three identical):
// golden's `uvm_pkg::uvm_default_printer` (uvm_object_globals.svh:637,
// `uvm_printer uvm_default_printer = uvm_default_table_printer;`) carries
// vpiExpr = ref_obj'uvm_default_table_printer' whose **vpiActual** is the
// package's own `class_var uvm_default_table_printer`.  We emit the identical
// class_var and the identical ref_obj and leave vpiActual NULL.  (The brief's
// framing — "the class_var is MISSING, the fix ADDS the variable" — is
// REFUTED: r10uvm47pv shows all twelve package class_vars present with
// matching kind/name/fullname/both spans/vpiAutomatic/vpiVisibility/typespec.
// The single missing thing is this ONE scalar pointer.)
//
// Every cell below separates one candidate GATE.  Read golden on each BEFORE
// writing emitter code; a law that only ever saw the uvm spelling
// (class handle, BACKWARD reference, bare name, own package) has four
// unmeasured halves.
//
//   c_ctor   `= new()` — the control: no ref_obj at all (expr is method_func_call)
//   b_back   class handle, BACKWARD reference   <- the uvm spelling
//   i_back   INTEGRAL keyword-typed variable, backward reference
//   i_expr   the ref_obj nested inside an OPERATION, not the whole initialiser
//   n_back   the NET arm (a user typedef resolving to a packed vector), backward
//   s_back   a string variable, backward
//   q_qual   an explicitly `pkg::`-QUALIFIED reference to this package's own var
//
// The FORWARD-reference cell is golden-only and lives in t65b (slang enforces
// the LRM and rejects a use-before-declaration inside a package).
//
// p2 re-measures the same cells through a WILDCARD IMPORT clone, because
// SeqDriver's `adpcm_pkg` clone of uvm_pkg's listing binds the CLONE's own
// object (`adpcm_pkg::uvm_default_table_printer`), not uvm_pkg's — so "which
// listing does the binding come from" is a real, already-observed question.
// p3 reads a reference to ANOTHER package's variable, bare and qualified.

package p1;

  class cls_a;
    int x;
  endclass

  typedef logic [3:0] w4;

  cls_a  a_first = new();          // c_ctor
  cls_a  a_back  = a_first;        // b_back  <- the uvm_default_printer shape

  int    i_first = 7;
  int    i_back  = i_first;        // i_back
  int    i_expr  = i_first + 1;    // i_expr

  w4     n_first = 4'h5;
  w4     n_back  = n_first;        // n_back (the NET arm)

  string s_first = "hello";
  string s_back  = s_first;        // s_back

  int    q_qual  = p1::i_first;    // q_qual

endpackage

package p2;
  import p1::*;
  int p2_own = 3;
  int p2_back = p2_own;
endpackage

package p3;
  import p1::*;
  int p3_from_p1 = i_first;        // bare imported name
  int p3_qual    = p1::i_first;    // qualified other-package name
endpackage

module t65a;
  import p1::*;
  import p3::*;
  initial begin
    $display("%0d %0d %0d", i_back, p2::p2_back, p3_from_p1);
  end
endmodule
