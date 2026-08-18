// r10buvm16 — THE PACKAGE-ONLY ARM.  This is the arm that mirrors the corpus
// head: `BuildUVMPkg` compiles `uvm_pkg.sv` and NOTHING ELSE, so there is no
// elaborated module instance anywhere in the design.
//
// WHY IT EXISTS SEPARATELY FROM a1.  a1 has a top module, and Surelog's
// elaboration invents an IMPLICIT NET in that module for every name a package
// routine failed to resolve — so a1's golden shows the SAME site twice, BARE in
// the package's own copy and bound to `logic_net (work@top16.<name>)` in the
// elaborated one.  That implicit-net residue is not this pass's law and would
// mask it; here there is no module, so every copy is the def-view copy and the
// reading is clean.
package q16;

   int pkgv16 = 4;
   int pkgarr16[];

   class d16;
      int prop16;
      int dyn16[];
      int decl16[] = new[pkgv16];         // p00 property DECL init, package var

      function int sz16(int a16);
         return a16;
      endfunction

      extern function void oob16(int g16);
      extern task oobt16(int gt16);
      extern static function void oobs16(int gs16);

      function void inb16(int f16);       // the IN-BODY control
         int loc16;
         loc16 = 1;
         dyn16 = new[loc16];              // p50 in-body: local
         dyn16 = new[f16];                // p51 in-body: formal
      endfunction
   endclass

   function void d16::oob16(int g16);
      int oloc16;
      int odyn16[];
      oloc16 = 3;
      dyn16   = new[oloc16];              // p01 OOB: LOCAL          (head shape)
      dyn16   = new[g16];                 // p02 OOB: FORMAL
      dyn16   = new[prop16];              // p03 OOB: CLASS PROPERTY
      dyn16   = new[this.prop16];         // p04 OOB: PROPERTY via this
      dyn16   = new[pkgv16];              // p05 OOB: PACKAGE VAR
      dyn16   = new[7];                   // p06 OOB: CONSTANT
      dyn16   = new[oloc16 + g16];        // p07 OOB: OPERATION
      dyn16   = new[sz16(oloc16)];        // p08 OOB: NESTED CALL     (76197 shape)
      odyn16  = new[oloc16](dyn16);       // p09 OOB: TWO-ARG copy    (76250 shape)
      odyn16  = new[odyn16.size()](odyn16); // p10 OOB: size() + copy (76250 exact)
      odyn16  = new[pkgarr16.size()];     // p11 OOB: package array size()
      this.dyn16 = new[oloc16];           // p12 OOB: THIS target
      if (oloc16 > 1) begin
         dyn16 = new[oloc16];             // p13 OOB: inside if-begin
      end
      begin : nb16
         int nbl16;
         nbl16 = 1;
         dyn16 = new[nbl16];              // p14 OOB: NAMED-block local
      end
      for (int it16 = 0; it16 < 2; it16++)
         dyn16 = new[it16];               // p15 OOB: for-loop iterator
   endfunction

   task d16::oobt16(int gt16);
      int tloc16;
      tloc16 = 1;
      dyn16 = new[tloc16];                // p20 OOB TASK: local
      dyn16 = new[gt16];                  // p21 OOB TASK: formal
   endtask

   function void d16::oobs16(int gs16);
      int sloc16;
      int sdyn16[];
      sloc16 = 1;
      sdyn16 = new[sloc16];               // p30 OOB STATIC: local
      sdyn16 = new[gs16];                 // p31 OOB STATIC: formal
      sdyn16 = new[pkgv16];               // p32 OOB STATIC: package var
   endfunction

   function automatic void pf16(int q16);
      int qloc16;
      int qdyn16[];
      qloc16 = 2;
      qdyn16 = new[qloc16];               // p40 PACKAGE fn: local
      qdyn16 = new[q16];                  // p41 PACKAGE fn: formal
      qdyn16 = new[pkgv16];               // p42 PACKAGE fn: package var
      qdyn16 = new[qloc16](qdyn16);       // p43 PACKAGE fn: two-arg copy
   endfunction

   task automatic pt16(int t16);
      int tqloc16;
      int tqdyn16[];
      tqloc16 = 2;
      tqdyn16 = new[tqloc16];             // p44 PACKAGE task: local
      tqdyn16 = new[t16];                 // p45 PACKAGE task: formal
   endtask

   int pkgdecl16[] = new[pkgv16];         // p60 PACKAGE var DECL init
endpackage
