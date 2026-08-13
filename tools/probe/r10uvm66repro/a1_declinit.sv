// r10uvm66 arm a1 — WHAT A SUBROUTINE-LOCAL DECLARATION WITH AN INITIALIZER
// CONTRIBUTES TO THE ENCLOSING STATEMENT LIST, and who owns the variable.
//
// The head this pass exists to clear is uvm-1.2 src/base/uvm_links.svh:251-257
//
//    251  static function uvm_cause_effect_link get_link(uvm_object lhs,
//    252                                                 uvm_object rhs,
//    253                                                 string name="ce_link");
//    254     uvm_cause_effect_link ce_link = new(name);
//    255     ce_link.set(lhs, rhs);
//    256     return ce_link;
//    257  endfunction : get_link
//
// golden's begin @255:7-255:29 holds TWO statements (method_func_call `set`,
// return_stmt) and parents `ce_link` on the BEGIN; ours holds THREE (an
// `assignment` opType 82 for the `= new(name)` initializer, first) and parents
// `ce_link` on that ASSIGNMENT.  m01 is that shape verbatim.
//
// Every other cell exists to separate ONE candidate term.  m07 is the control
// that matters most: the SAME construction written as a STATEMENT rather than as
// a declaration initializer.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

package a1p;

   class a1base;
      int m_lhs, m_rhs;
      function new(string name="unnamed");
      endfunction : new
      function void set(int lhs, int rhs);
         m_lhs = lhs;
         m_rhs = rhs;
      endfunction : set
   endclass

   class a1c extends a1base;
      int fld;

      function new(string name="unnamed-a1c");
         super.new(name);
      endfunction : new

      // m01 — THE CORPUS SHAPE VERBATIM: class-handle local, `new(arg)`
      //       initializer, then a method call, then a return.
      static function a1c m01_corpus(int lhs, int rhs, string name="ce_link");
         a1c ce = new(name);
         ce.set(lhs, rhs);
         return ce;
      endfunction : m01_corpus

      // m02 — `new()` with NO argument.
      function void m02_newnoarg();
         a1c ce = new();
         ce.set(1, 2);
      endfunction : m02_newnoarg

      // m03 — the decl+init is the WHOLE body (a decl-only body: golden is
      //       already known bare here, § 65 c17/c21).
      function void m03_only();
         a1c ce = new();
      endfunction : m03_only

      // m04 — `int x = 5;` — an INTEGRAL local with a CONSTANT initializer.
      function void m04_intconst();
         int x = 5;
         fld = x;
      endfunction : m04_intconst

      // m05 — integral local, initializer is an EXPRESSION over a formal.
      function void m05_intexpr(int lhs);
         int x = lhs + 1;
         fld = x;
      endfunction : m05_intexpr

      // m06 — class handle initialized from a FUNCTION CALL, not `new`.
      function void m06_fromcall();
         a1c ce = m01_corpus(1, 2, "x");
         ce.set(1, 2);
      endfunction : m06_fromcall

      // m07 — THE CONTROL THAT DECIDES THE LAW'S SHAPE: the same construction
      //       written as a STATEMENT, with the declaration left bare.
      //       § thisSuperNewAssignNoStmt3 measured `ce = new(...)` on a BARE
      //       local as KEPT, so if golden keeps this and drops m01 the term is
      //       the DECLARATION INITIALIZER, not the `new`.
      function void m07_stmtnew(string name);
         a1c ce;
         ce = new(name);
         ce.set(1, 2);
      endfunction : m07_stmtnew

      // m08 — dynamic-array local with a `new[]` initializer.
      function void m08_dynnew();
         int d[] = new[3];
         fld = 1;
      endfunction : m08_dynnew

      // m09 — TWO declarations, both initialized.
      function void m09_two();
         int x = 1;
         int y = 2;
         fld = x + y;
      endfunction : m09_two

      // m10 — declaration with NO initializer (control: neither side has a
      //       statement for it).
      function void m10_noinit();
         int x;
         x = 5;
         fld = x;
      endfunction : m10_noinit

      // m11 — decl+init inside an EXPLICIT begin/end nested in the body.
      function void m11_nested();
         fld = 0;
         begin
            a1c ce = new();
            ce.set(1, 2);
         end
      endfunction : m11_nested

      // m12 — decl+init inside a NAMED begin.
      function void m12_named();
         fld = 0;
         begin : m12blk
            a1c ce = new();
            ce.set(1, 2);
         end : m12blk
      endfunction : m12_named

      // m13 — a TASK with a decl+init.
      task m13_task(int a);
         a1c ce = new();
         ce.set(a, 2);
      endtask : m13_task

      // m14 — the CLASS CONSTRUCTOR's own statement list (compiled through
      //       compileClassConstructorDeclaration, § constructorBodyElementShift27).
      //       Kept in its own class so a1c::new stays the corpus shape.

      // m15 — string local with a constant initializer.
      function void m15_string();
         string s = "abc";
         fld = 1;
      endfunction : m15_string

      // m16 — decl+init followed ONLY by a return.
      function a1c m16_declret(string name);
         a1c ce = new(name);
         return ce;
      endfunction : m16_declret

      // m17 — class handle initialized to `null`.
      function void m17_null();
         a1c ce = null;
         fld = 1;
      endfunction : m17_null

      // m18 — integral local initialized from a plain ref (a formal).
      function void m18_intref(int lhs);
         int x = lhs;
         fld = x;
      endfunction : m18_intref

      // m19 — decl+init then a FOR loop, so the surviving list has a
      //       non-trivial second element.
      function void m19_thenfor();
         int x = 1;
         for (int i = 0; i < 2; i++)
            fld = x + i;
      endfunction : m19_thenfor

      // m20 — TWO class handles, both `new`-initialized, then two calls.
      function void m20_twonew();
         a1c p = new();
         a1c q = new();
         p.set(1, 2);
         q.set(3, 4);
      endfunction : m20_twonew

      // m21 — an initialized local of a QUEUE type.
      function void m21_queue();
         int q[$] = {1, 2};
         fld = 1;
      endfunction : m21_queue

      // m22 — `automatic` spelled out.
      function void m22_automatic();
         automatic int x = 5;
         fld = x;
      endfunction : m22_automatic

   endclass

   // m14 — the constructor cell, in its own class.
   class a1ctor;
      int fld;
      a1c h;
      function new();
         a1c ce = new();
         ce.set(1, 2);
         fld = 1;
      endfunction : new
   endclass

   // m23 — a PACKAGE FREE FUNCTION with a decl+init.
   function automatic int m23_pkgfn(int a);
      int x = a + 1;
      return x;
   endfunction : m23_pkgfn

   // m24 — a package free function with a CLASS-HANDLE decl+init.
   function automatic void m24_pkgnew();
      a1c ce = new();
      ce.set(1, 2);
   endfunction : m24_pkgnew

endpackage

// m25/m26 — MODULE scope.
module a1mod;
   import a1p::*;
   int fld;

   function automatic int m25_modfn(int a);
      int x = a + 1;
      return x;
   endfunction : m25_modfn

   task automatic m26_modtask(int a);
      a1c ce = new();
      ce.set(a, 2);
   endtask : m26_modtask

   // m27 — an INITIAL block's own begin (not a subroutine at all).
   initial begin
      int x = 5;
      fld = x;
   end
endmodule
