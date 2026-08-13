// r10uvm66 arm a4 — THE RESIDUE ARM, built to make residue 1 precise rather
// than to change any gate.
//
// The indent-blind removed-text audit (mvrem66.sh) showed ONE family crossing
// golden after the patch, and it decomposes to a PRE-EXISTING and UNCHANGED
// deficit: golden gives 41 `vpiExpr` occurrences of a `new` method_func_call to
// MEMBER-LEVEL class-handle variables (SimpleUVM), we give 31, and the patch
// moves neither number (31 before, 31 after).  Its owners in golden are all
// written with NO PARENTHESES:
//
//   uvm_printer.svh:81    uvm_printer_knobs knobs = new;
//   uvm_comparer.svh:419  uvm_scope_stack   scope = new;
//   uvm_transaction:409   const uvm_event_pool events = new;
//
// while arm a2 n16 — a class property written `a2c h = new();` WITH parens — has
// NO vpiExpr in golden either.  So the candidate discriminator is the written
// PARENTHESES, and this arm tests it directly at both member levels.  Nothing
// here is a statement list; § declInitWrittenNewNoStmt66 does not reach any of it.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

package a4p;

   class a4inner;
      int fld;
      function new();
      endfunction : new
   endclass

   class a4host;
      // r01 — class property, `new` with NO PARENS (the UVM spelling).
      a4inner r01_noparens = new;
      // r02 — class property, `new()` WITH parens (the a2 n16 spelling).
      a4inner r02_parens = new();
      // r03 — `const` + no parens (the uvm_transaction::events spelling).
      const a4inner r03_const = new;
      // r04 — `static` + no parens.
      static a4inner r04_static = new;
      // r05 — no parens, with an ARGUMENT is impossible; the argument form
      //       always writes parens, so r05 is `new(1)` for the contrast.
      a4inner r05_arg = new();
      int fld;
      function void touch();
         fld = 1;
      endfunction : touch
   endclass

   // r06 — PACKAGE-scope variable, no parens (the uvm_global_vars spelling).
   a4inner r06_pkg_noparens = new;
   // r07 — PACKAGE-scope variable, with parens.
   a4inner r07_pkg_parens = new();

endpackage

module a4mod;
   import a4p::*;
   // r08 — MODULE-scope variable, no parens.
   a4inner r08_mod_noparens = new;
   // r09 — MODULE-scope variable, with parens.
   a4inner r09_mod_parens = new();
   int fld;
   initial fld = 1;
endmodule
