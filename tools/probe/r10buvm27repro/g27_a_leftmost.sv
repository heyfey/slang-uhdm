// r10buvm27 grid A -- $bits over EXPRESSIONS (operations), class in-block home
package pA;
  typedef struct packed { bit [3:0] hi; bit [7:0] lo; } sp_t;   // 12
  class C;
    byte unsigned      b8;
    byte unsigned      dyn [];
    bit  [31:0]        v32;
    bit  [15:0]        v16;
    int                ii;
    shortint           si;
    sp_t               sp;
    string             st;
    real               rr;
    logic [7:0]        pk4 [4];
    typedef enum bit [2:0] { E0, E1 } e_t;
    e_t                ee;
    function int f(int a); return a; endfunction
    function void m();
      int r;
      // ---- 1-operand baselines
      r = $bits(b8);                 // c01
      r = $bits(v32);                // c02
      r = $bits(dyn[0]);             // c03
      // ---- binary, leftmost NAME vs rightmost NAME (different widths)
      r = $bits(b8 & v32);           // c04
      r = $bits(v32 & b8);           // c05
      r = $bits(b8 + v32);           // c06
      r = $bits(v32 + b8);           // c07
      r = $bits(b8 | v16);           // c08
      r = $bits(v16 | b8);           // c09
      // ---- the head's own shape
      r = $bits(dyn[0] & b8);        // c10
      r = $bits(b8 & dyn[0]);        // c11
      r = $bits(v32[3] & b8);        // c12
      r = $bits(pk4[1] & b8);        // c13
      // ---- literal leftmost / rightmost
      r = $bits(b8 & 8'hFF);         // c14
      r = $bits(8'hFF & b8);         // c15
      r = $bits(32'hFF & b8);        // c16
      // ---- unary / paren / ternary / concat / repl
      r = $bits(~b8);                // c17
      r = $bits((b8 & v32));         // c18
      r = $bits(ii ? b8 : v32);      // c19
      r = $bits({b8, v32});          // c20
      r = $bits({2{b8}});            // c21
      // ---- member leftmost
      r = $bits(sp.hi & b8);         // c22
      r = $bits(sp & b8);            // c23
      // ---- non-integral leftmost
      r = $bits(st == "a");          // c24
      r = $bits(rr + 1.0);           // c25
      r = $bits(ee & b8);            // c26
      // ---- call leftmost
      r = $bits(f(1) & b8);          // c27
      // ---- comparison / logical (1-bit results)
      r = $bits(b8 == v32);          // c28
      r = $bits(b8 && v32);          // c29
      r = $bits(b8 << 2);            // c30
      r = $bits(si * b8);            // c31
      $display("%0d", r);
    endfunction
  endclass
endpackage
module gA;
  import pA::*;
  initial begin C c = new(); c.m(); end
endmodule
