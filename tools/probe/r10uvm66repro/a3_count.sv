// r10uvm66 arm a3 — THE COUNTING ARM: does a DROPPED declaration assignment
// still count toward the body's `begin`-wrapper decision?
//
// a2 produced two cells that cannot both be explained by "drop the element":
//
//   n07  a body whose EVERY element is a `new`-initialized declaration:
//        golden keeps the wrapper and it is **EMPTY**  ->  the dropped element
//        STILL COUNTED.
//   n24  a TF-ITEM body (non-ANSI body io) with one `new` decl and one real
//        statement: golden takes **NO WRAPPER AT ALL** and parents the local on
//        the TASK  ->  the dropped element did NOT count.
//
// The candidate reconciliation, read off § constructorBodyElementShift27's
// model (2): a BLOCK-ITEM declaration is compiled as a body STATEMENT (an
// assignment, Rhs present only with an initializer) and compileFunction filters
// the Rhs-less ones out AFTER the wrapper decision — while a TF-ITEM
// declaration is a `tf_item_declaration` and never becomes a statement at all.
// That model predicts p03: a TF-ITEM body with an ORDINARY `int x = 5;`
// initializer ALSO takes no wrapper and produces NO assignment.
//
// If p03 confirms it, the tf-item family is a SEPARATE law and n24's wrapper is
// its residue, not this pass's; if p03 refutes it, the count must be gated.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

package a3p;
   class a3c;
      int fld;
      function new(string name="a3c");
      endfunction : new
      function void set(int lhs, int rhs);
         fld = lhs + rhs;
      endfunction : set
   endclass

   class a3host;
      int fld;

      // p01 — BLOCK-ITEM decls, NO initializers, NO statement.
      function void p01_bidnoinit();
         int x;
         int y;
      endfunction : p01_bidnoinit

      // p02 — BLOCK-ITEM decls, no initializers, ONE statement.
      function void p02_bidnoinit1(int a);
         int x;
         int y;
         fld = a;
      endfunction : p02_bidnoinit1

      // p05 — ONE uninitialized BLOCK-ITEM decl + ONE statement.
      function void p05_bid1(int a);
         int x;
         fld = a;
      endfunction : p05_bid1

      // p10 — an uninitialized decl AND a `new`-initialized decl, no statement.
      function void p10_mix();
         int x;
         a3c q = new();
      endfunction : p10_mix

      // p11 — ONE `new`-initialized decl + ONE statement (the plain shape, for
      //       the wrapper baseline).
      function void p11_one(int a);
         a3c q = new();
         fld = a;
      endfunction : p11_one
   endclass
endpackage

module a3mod;
   import a3p::*;
   int fld;

   // p03 — TF-ITEM body, ORDINARY `int x = 5;` initializer.  THE PREDICTION
   //       CELL: no wrapper and no assignment, if a tf_item_declaration never
   //       becomes a statement.
   task p03_tfint;
      input int a;
      int x = 5;
      fld = a + x;
   endtask : p03_tfint

   // p04 — TF-ITEM body, TWO real statements (the wrapper control).
   task p04_tftwo;
      input int a;
      fld = a;
      fld = fld + 1;
   endtask : p04_tftwo

   // p06 — TF-ITEM body, uninitialized decl + ONE statement.
   task p06_tfnoinit;
      input int a;
      int x;
      fld = a;
   endtask : p06_tfnoinit

   // p07 — TF-ITEM body, dynamic-array `new[]` decl + ONE statement.
   task p07_tfdyn;
      input int a;
      int d[] = new[3];
      fld = a;
   endtask : p07_tfdyn

   // p08 — TF-ITEM body, a `new`-initialized decl and NO real statement.
   task p08_tfonly;
      input int a;
      a3c q = new();
   endtask : p08_tfonly

   // p09 — TF-ITEM body, ORDINARY init and NO real statement.
   task p09_tfintonly;
      input int a;
      int x = 5;
   endtask : p09_tfintonly

   // p12 — an ANSI-ported task (block items) with an ordinary init + a
   //       statement, as the block-item twin of p03.
   task automatic p12_bidint(input int a);
      int x = 5;
      fld = a + x;
   endtask : p12_bidint
endmodule
