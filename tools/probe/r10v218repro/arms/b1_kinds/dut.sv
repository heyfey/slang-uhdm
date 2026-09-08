// r10v218 arm b1 — SYMBOL-KIND and POSITION axes the implementer's a2 does not
// carry, inside an UNINSTANTIATED interface.  Every cell asks: does golden give
// the reference a vpiActual?  A cell where golden is BARE and the PATCHED
// binary binds is a REGRESSION; a cell where golden binds and neither binary
// does is a residue.
package p1v;
   typedef enum { P1V_A, P1V_B } p1v_t;
   localparam int P1V_K = 3;
endpackage

class c1v;
   function void take(int x); endfunction
   function int  give(int x); return x; endfunction
endclass

interface if1v;                              // NEVER instantiated
   import p1v::*;
   bit  mv1v;
   int  shad1v;                              // SHADOWED by a body local below
   localparam int MP1V = 7;
   c1v h1v;

   typedef struct packed { bit a; bit b; } s1v_t;

   // ------------------------------------------------------------------ TASK
   task automatic t1v(int a_t, output int a_o, inout int a_io, ref int a_r);
      int tloc1v;
      if (a_t == 1) mv1v = 1'b1;             // k01 TASK formal, cond
      if (a_o == 1) mv1v = 1'b1;             // k02 OUTPUT formal, cond
      if (a_io == 1) mv1v = 1'b1;            // k03 INOUT formal, cond
      if (a_r == 1) mv1v = 1'b1;             // k04 REF formal, cond
      if (tloc1v == 1) mv1v = 1'b1;          // k05 TASK local, cond
      callee1v(a_t);                         // k06 TASK formal, call-stmt arg
      callee1v(tloc1v);                      // k07 TASK local,  call-stmt arg
      a_o = a_t;                             // k08 output lvalue / rvalue
   endtask

   // -------------------------------------------------------------- FUNCTION
   function int f1v(int a_x);
      int loc1v;
      static int stat1v;                     // STATIC subroutine local
      automatic int auto1v = 0;              // AUTOMATIC with initialiser
      int shad1v;                            // SHADOWS the interface member
      s1v_t st1v;
      int arr1v[4];
      p1v_t e1v;
      if (stat1v == 1) mv1v = 1'b1;          // k09 STATIC local, cond
      if (auto1v == 1) mv1v = 1'b1;          // k10 AUTOMATIC local, cond
      if (shad1v == 1) mv1v = 1'b1;          // k11 SHADOWING local, cond
      if (st1v.a == 1) mv1v = 1'b1;          // k12 struct MEMBER of a local
      if (arr1v[1] == 1) mv1v = 1'b1;        // k13 constant select of a local
      if (e1v == P1V_A) mv1v = 1'b1;         // k14 enum-typed local, cond
      if (f1v == 1) mv1v = 1'b1;             // k15 the FUNCTION RETURN NAME
      callee1v(f1v);                         // k16 return name, call-stmt arg
      callee1v(stat1v);                      // k17 STATIC local, call arg
      callee1v(shad1v);                      // k18 SHADOWING local, call arg
      callee1v(st1v.a);                      // k19 struct member, call arg
      callee1v(a_x ? loc1v : auto1v);        // k20 TERNARY operands, call arg
      $display("%0d", a_x);                  // k21 SYSTEM TASK argument
      dpi1v(a_x);                            // k22 DPI IMPORT call argument
      case (a_x)                             // k23 CASE condition
        0: mv1v = 1'b1;
        default: mv1v = 1'b0;
      endcase
      case (1'b1)
        (loc1v == 1): mv1v = 1'b1;           // k24 CASE ITEM expression
        default: mv1v = 1'b0;
      endcase
      assert (a_x == 1) else mv1v = 1'b0;    // k25 IMMEDIATE ASSERT condition
      repeat (a_x) mv1v = 1'b1;              // k26 REPEAT count
      foreach (arr1v[i1v])                   // k27 FOREACH loop variable
        if (i1v == 0) mv1v = 1'b1;
      begin
         int u1v;
         begin
            int u2v;
            if (u2v == 1) mv1v = 1'b1;       // k28 unnamed block, DEPTH TWO
         end
         if (u1v == 1) mv1v = 1'b1;          // k29 unnamed block, depth one
         callee1v(u1v);                      // k30 unnamed-block local, arg
      end
      return loc1v;                          // k31 RETURN operand
   endfunction

   function void callee1v(int z); endfunction
   import "DPI-C" function void dpi1v(input int z);
endinterface

module top1v;
   initial begin end
endmodule
