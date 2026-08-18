// r10buvm16 — THE `new` GRID.  Purpose-built GOLDEN measurement arm.
//
// Every cell is a `new[...]` allocation or a `new(...)` construction whose SIZE
// / ARGUMENT expression is one of the shapes the brief names, crossed with the
// subroutine kind that hosts it.  What is being read at each cell is whether
// golden's argument `ref_obj` carries a `vpiActual` — nothing else.
//
// Cell ids are in the comments; the variable names are unique per cell so a
// dump can be grepped by name.
package p16;

   int pkgv16 = 4;

   class base16;
      int bprop16;
      function new(int a16);
         bprop16 = a16;
      endfunction
   endclass

   class c16 extends base16;
      int prop16;
      int dyn16[];
      int ddecl16[] = new[7];             // m00 DECLARATION initializer, const
      c16 h16;

      function new(int n16);
         int nloc16;
         super.new(n16);                  // m90 super.new control (formal)
         nloc16 = 2;
         dyn16 = new[nloc16];             // m91 ctor body, local
         dyn16 = new[n16];                // m92 ctor body, formal
      endfunction

      function int sz16(int a16);
         return a16;
      endfunction

      function void inbody16(int f16);
         int loc16;
         int src16[];
         loc16 = 3;
         dyn16 = new[loc16];              // m01 in-body: LOCAL
         dyn16 = new[f16];                // m02 in-body: FORMAL
         dyn16 = new[prop16];             // m03 in-body: PROPERTY (bare)
         dyn16 = new[this.prop16];        // m04 in-body: PROPERTY via this
         dyn16 = new[pkgv16];             // m05 in-body: PACKAGE var
         dyn16 = new[7];                  // m06 in-body: CONSTANT
         dyn16 = new[loc16 + f16];        // m07 in-body: OPERATION
         dyn16 = new[sz16(loc16)];        // m08 in-body: CALL
         dyn16 = new[loc16](src16);       // m09 in-body: TWO-ARG copy
         src16 = new[loc16];              // m10 in-body: LOCAL target
         this.dyn16 = new[loc16];         // m11 in-body: THIS target
         h16 = new(loc16);                // m12 in-body: CLASS new, local arg
         h16 = new(f16);                  // m13 in-body: CLASS new, formal arg
      endfunction

      extern function void oob16(int g16);

      static function void st16(int h16s);
         int sloc16;
         int sdyn16[];
         sloc16 = 1;
         sdyn16 = new[sloc16];            // m20 STATIC: local
         sdyn16 = new[h16s];              // m21 STATIC: formal
         sdyn16 = new[pkgv16];            // m22 STATIC: package var
         sdyn16 = new[7];                 // m23 STATIC: constant
      endfunction

      task tk16(int k16);
         int tloc16;
         tloc16 = 1;
         dyn16 = new[tloc16];             // m30 TASK: local
         dyn16 = new[k16];                // m31 TASK: formal
      endtask

      function void reff16(ref int rr16[], int rf16);
         int rloc16;
         rloc16 = 1;
         rr16 = new[rloc16];              // m40 REF-FORMAL target, local size
         rr16 = new[rf16];                // m41 REF-FORMAL target, formal size
      endfunction
   endclass

   function void c16::oob16(int g16);
      int oloc16;
      int odyn16[];
      oloc16 = 3;
      dyn16 = new[oloc16];                // o01 OUT-OF-BODY: LOCAL
      dyn16 = new[g16];                   // o02 OUT-OF-BODY: FORMAL
      dyn16 = new[prop16];                // o03 OUT-OF-BODY: PROPERTY
      dyn16 = new[this.prop16];           // o04 OUT-OF-BODY: PROPERTY via this
      dyn16 = new[pkgv16];                // o05 OUT-OF-BODY: PACKAGE var
      dyn16 = new[7];                     // o06 OUT-OF-BODY: CONSTANT
      dyn16 = new[oloc16 + g16];          // o07 OUT-OF-BODY: OPERATION
      dyn16 = new[sz16(oloc16)];          // o08 OUT-OF-BODY: CALL
      odyn16 = new[oloc16](dyn16);        // o09 OUT-OF-BODY: TWO-ARG copy
      odyn16 = new[oloc16];               // o10 OUT-OF-BODY: LOCAL target
      this.dyn16 = new[oloc16];           // o11 OUT-OF-BODY: THIS target
      if (oloc16 > 1) begin
         dyn16 = new[oloc16];             // o12 OUT-OF-BODY inside if-begin
      end
      begin : nb16
         int nbl16;
         nbl16 = 1;
         dyn16 = new[nbl16];              // o13 NAMED-block local
      end
   endfunction

   function automatic void pf16(int q16);
      int qloc16;
      int qdyn16[];
      qloc16 = 2;
      qdyn16 = new[qloc16];               // q01 PACKAGE fn: local
      qdyn16 = new[q16];                  // q02 PACKAGE fn: formal
      qdyn16 = new[pkgv16];               // q03 PACKAGE fn: package var
      qdyn16 = new[7];                    // q04 PACKAGE fn: constant
      qdyn16 = new[qloc16 + q16];         // q05 PACKAGE fn: operation
      qdyn16 = new[qloc16](qdyn16);       // q06 PACKAGE fn: two-arg copy
   endfunction

   task automatic pt16(int t16);
      int tqloc16;
      int tqdyn16[];
      tqloc16 = 2;
      tqdyn16 = new[tqloc16];             // q10 PACKAGE task: local
      tqdyn16 = new[t16];                 // q11 PACKAGE task: formal
   endtask

endpackage

module top16;
   import p16::*;
   int mv16 = 5;
   int mdyn16[];
   int mdecl16[] = new[3];                // u00 module DECLARATION initializer

   initial begin
      int iloc16;
      iloc16 = 4;
      mdyn16 = new[mv16];                 // u01 INITIAL: module var
      mdyn16 = new[iloc16];               // u02 INITIAL: block local
      mdyn16 = new[7];                    // u03 INITIAL: constant
      mdyn16 = new[iloc16](mdyn16);       // u04 INITIAL: two-arg copy
   end

   function automatic void mf16(int r16);
      int rloc16;
      int rdyn16[];
      rloc16 = 1;
      rdyn16 = new[rloc16];               // u10 MODULE fn: local
      rdyn16 = new[r16];                  // u11 MODULE fn: formal
      rdyn16 = new[mv16];                 // u12 MODULE fn: module var
   endfunction
endmodule
