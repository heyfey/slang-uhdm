// r10uvm66 VERIFIER arm v2 — THE CONSTRUCTOR EXCLUSION'S OWN BOUNDARY.
//
// The law excludes "the class CONSTRUCTOR's own list" and implements that by
// simply NOT calling the predicate from emitCtorBody27's EK_BID arm.  But a
// constructor body can hold a WRITTEN `begin ... end`, and a written block is
// emitted by CALL SITE 1, which carries no constructor gate at all (its comment
// in StmtEmit.cpp says so out loud for § 3: "call sites 1 and 2 carry NO
// constructor gate").  So inside a constructor the SAME declaration is dropped
// or kept depending on whether the author wrote a `begin` around it — and
// nothing in a1/a2/a3 measures that.
//
// x01 is the constructor's own list (a2 n01 restated, so this arm carries the
// known answer as its own control).  x02 puts the identical declaration one
// `begin` deeper in the SAME constructor.  x03 is a nested block in an ORDINARY
// method, the shape whose answer is already known (a1 m11), so a disagreement
// between x02 and x03 isolates "inside a constructor" as the term.
// x04/x05 measure the same pair for the DYNAMIC-ARRAY `new[]`.
// x06 is an out-of-body constructor; x07 a constructor with a `super.new` call
// ahead of the declaration (the element-shift family § 27 owns).
package v2p;

   class v2c;
      int fld;
      function void set(int a, int b);
         fld = a + b;
      endfunction : set
   endclass

   class v2base;
      int b;
      function new(int s);
         b = s;
      endfunction : new
   endclass

   // x01 — the CONSTRUCTOR'S OWN LIST, with a PORT LIST so that
   //       § constructorBodyElementShift27 cannot eat the first element.
   class v2ctor;
      int fld;
      function new(int seed);
         v2c ce = new();
         ce.set(seed, 2);
         fld = seed;
      endfunction : new
   endclass

   // x02 — the SAME declaration, one WRITTEN `begin` deeper, in a constructor.
   class v2ctorblk;
      int fld;
      function new(int seed);
         begin
            v2c ce = new();
            ce.set(seed, 2);
         end
         fld = seed;
      endfunction : new
   endclass

   // x03 — the control: a nested written `begin` in an ORDINARY method.
   class v2meth;
      int fld;
      function void x03_nested(int seed);
         begin
            v2c ce = new();
            ce.set(seed, 2);
         end
         fld = seed;
      endfunction : x03_nested
   endclass

   // x04 — dynamic-array `new[]` in a constructor's own list.
   class v2ctordyn;
      int fld;
      function new(int seed);
         int d[] = new[3];
         fld = seed;
      endfunction : new
   endclass

   // x05 — dynamic-array `new[]` one `begin` deeper in a constructor.
   class v2ctordynblk;
      int fld;
      function new(int seed);
         begin
            int d[] = new[3];
            fld = seed;
         end
      endfunction : new
   endclass

   // x06 — an OUT-OF-BODY constructor definition.
   class v2oob;
      int fld;
      extern function new(int seed);
   endclass
   function v2oob::new(int seed);
      v2c ce = new();
      ce.set(seed, 2);
      fld = seed;
   endfunction

   // x07 — a constructor whose FIRST element is `super.new(...)`, with the
   //       declaration after it (§ 27's element-shift family).
   class v2ctorsuper extends v2base;
      int fld;
      function new(int seed);
         super.new(seed);
         begin
            v2c ce = new();
            ce.set(seed, 2);
         end
         fld = seed;
      endfunction : new
   endclass

endpackage
