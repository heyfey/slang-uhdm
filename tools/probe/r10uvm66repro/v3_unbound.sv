// r10uvm66 VERIFIER arm v3 — THE ONE PLACE THE SYNTAX KEYING AND THE OLD
// KIND KEYING CANNOT AGREE.
//
// The clause § declInitWrittenNewNoStmt66 replaced read
//     init->kind == ExpressionKind::NewClass          (the BOUND expression)
// and the shipped gate reads
//     getInitializerSyntax()->kind == NewClassExpression   (the WRITTEN node).
// ExprEmit.cpp:497 `sourceIsNewClassExpr55` documents, with slang source
// citations, that slang REFUSES to bind `new` in two shapes uvm-1.2 "hits
// constantly" and returns an `InvalidExpression` that still carries the
// `NewClassExpressionSyntax`:  (a) an ABSTRACT (`virtual`) class target,
// (b) a target that is not a class at all.  For those, the OLD clause could not
// fire and the NEW one does — a behaviour change in the pass that its README
// does not claim and no arm cell measures.  Golden (Surelog) never type-checks
// the construct, so if the law is right, golden drops these too.
//
// y01 = ABSTRACT class target; y03 = the control that binds normally.
// TWO CELLS WERE DELETED AND THAT IS REPORTED, NOT HIDDEN: `int h = new();`
// (non-class target) makes SLANG exit with a hard error and emit NO database,
// and `v3real h = new[3];` makes SURELOG exit with 3 SYNTAX errors and emit no
// golden.  Neither is measurable at package scope; § 55's comment locates the
// suppressed-diagnostic population inside a GENERIC class's default
// specialization, which this arm does not reproduce.
package v3p;

   virtual class v3abs;
      int fld;
      pure virtual function void go();
   endclass

   class v3real;
      int fld;
      function void set(int a, int b);
         fld = a + b;
      endfunction : set
   endclass

   class v3host;
      int fld;

      // y03 — CONTROL: binds normally, so the arm carries a known-moving cell.
      function void y03_ok();
         v3real ce = new();
         ce.set(1, 2);
      endfunction : y03_ok


   endclass

   // y01 — THE § 55 SHAPE, reproduced the way § 55 locates it: a GENERIC class
   //       whose DEFAULT type parameter is the ABSTRACT class, so slang's
   //       `resolveNewClassTarget` refuses the bind and SUPPRESSES the
   //       diagnostic in the default specialization (at plain package scope the
   //       same line is a hard slang error and no database is emitted at all --
   //       measured, and that is why the cell is written this way).
   class v3gen #(type T = v3abs);
      int fld;
      function void y01_abstract();
         T h = new();
         fld = 1;
      endfunction : y01_abstract
   endclass

endpackage
