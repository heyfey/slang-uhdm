// r10uvm66 VERIFIER arm v1 — the corners § declInitWrittenNewNoStmt66's own
// grid does NOT contain.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// The shipped gate is exactly
//     isyn->kind == NewClassExpression || isyn->kind == NewArrayExpression
// and the README states "no static/const/automatic/local test" as a PROPERTY of
// the law.  a1 m22 measures `automatic int x = 5` (not a `new`) and NO cell
// measures a QUALIFIED declaration whose initializer IS a `new`.  A `static`
// local is initialised ONCE, not on entry, so it is the one qualifier that could
// plausibly compile to a different statement shape — if golden KEEPS the
// assignment for it, the shipped gate OVER-FIRES and the law needs a qualifier
// term.  w01..w04 measure all four spellings against the unqualified control.
//
// w05/w06 measure `new <handle>` — SyntaxKind::CopyClassExpression, the THIRD
// `new` form.  src/ParamEmit.cpp:20302 already treats it as a `new` initializer
// for its own netShape26 decision; the shipped § 66 gate does NOT list it and no
// arm cell measures it.  Either answer is informative: dropped by golden = the
// gate is one term short (UNDER-fire); kept = the omission is correct.
package v1p;

   class v1c;
      int fld;
      function void set(int a, int b);
         fld = a + b;
      endfunction : set
   endclass

   class v1host;
      int fld;

      // w00 — the CONTROL: the shipped law's own shape (a1 m01), so the arm
      //       carries a cell known to move inside it.
      function void w00_plain();
         v1c ce = new();
         ce.set(1, 2);
      endfunction : w00_plain

      // w01 — `static` lifetime + `new`.
      function void w01_static();
         static v1c ce = new();
         ce.set(1, 2);
      endfunction : w01_static

      // w02 — `automatic` lifetime + `new`.
      function void w02_automatic();
         automatic v1c ce = new();
         ce.set(1, 2);
      endfunction : w02_automatic

      // w03 — `const` + `new`.
      function void w03_const();
         const v1c ce = new();
         ce.set(1, 2);
      endfunction : w03_const

      // w04 — `var` + `new`.
      function void w04_var();
         var v1c ce = new();
         ce.set(1, 2);
      endfunction : w04_var

      // w05 — the COPY form `new src`: CopyClassExpression, NOT in the gate.
      function void w05_copyclass();
         v1c src = new();
         v1c ce = new src;
         ce.set(1, 2);
      endfunction : w05_copyclass

      // w06 — the copy form ALONE, so w05's leading `new()` cannot mask it.
      function void w06_copyonly(v1c src);
         v1c ce = new src;
         ce.set(1, 2);
      endfunction : w06_copyonly

      // w07 — `static` on a DYNAMIC ARRAY `new[]`, the other half of the pair.
      function void w07_staticdyn();
         static int d[] = new[3];
         fld = 1;
      endfunction : w07_staticdyn

      // w08 — a `new` decl in a FOREACH body block (a slot a2 does not list).
      function void w08_foreach(int n[]);
         foreach (n[i]) begin
            v1c ce = new();
            ce.set(i, 2);
         end
      endfunction : w08_foreach

      // w09 — a `new` decl in a DO-WHILE body block.
      function void w09_dowhile();
         int i = 0;
         do begin
            v1c ce = new();
            ce.set(i, 2);
            i = i + 1;
         end while (i < 2);
      endfunction : w09_dowhile

      // w10 — a `new` decl in a REPEAT body block.
      function void w10_repeat();
         repeat (2) begin
            v1c ce = new();
            ce.set(1, 2);
         end
      endfunction : w10_repeat

      // w11 — a VIRTUAL method (§ 65 residue 3's span family) with a `new`
      //       decl: the two laws must not collide.
      virtual function void w11_virtual();
         v1c ce = new();
         ce.set(1, 2);
      endfunction : w11_virtual

   endclass

endpackage
