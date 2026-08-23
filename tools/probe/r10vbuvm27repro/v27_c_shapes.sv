// r10vbuvm27 ARM C -- SHAPE edge cases around the leftmost-operand rule.
`define BITSOF(X) $bits(X & be)
package pC2;
  typedef struct packed { bit [3:0] hi; bit [7:0] lo; } sp_t;
  class CC;
    byte unsigned dyn [];
    logic [7:0]   pk4 [4];
    bit [31:0]    v32;
    sp_t          sp;
    sp_t          spa [2];
    byte unsigned be;
    CC            hnd;
    int r; int i;
    function int f(int a); return a; endfunction
    function void m();
      r = $bits(dyn[i] & be);              // d01 baseline FOLD
      r = $bits((dyn[i]) & be);            // d02 paren   KEEP
      r = $bits(((dyn[i])) & be);          // d03 2 parens KEEP
      r = $bits(dyn[i] & be & be);         // d04 nested  KEEP
      r = $bits((dyn[i] & be) & be);       // d05 paren-nested KEEP
      r = $bits(dyn[i] & (be & be));       // d06 right-nested -> leftmost is dyn[i]
      r = $bits(be & dyn[i]);              // d07 select right KEEP
      r = $bits(~dyn[i] & be);             // d08 unary KEEP
      r = $bits(-pk4[i] & be);             // d09 unary minus KEEP
      r = $bits(8'(dyn[i]) & be);          // d10 cast KEEP
      r = $bits(int'(dyn[i]) & be);        // d11 type cast KEEP
      r = $bits(dyn[i] ? be : be);         // d12 ternary cond is select
      r = $bits(be ? dyn[i] : be);         // d13 ternary cond bare KEEP
      r = $bits((be) ? dyn[i] : be);       // d14
      r = $bits({dyn[i], be});             // d15 concat KEEP
      r = $bits({2{pk4[i]}});              // d16 replication
      r = $bits({dyn[i], be} & 16'd1);     // d17 concat-left
      r = $bits(f(1) & be);                // d18 call left KEEP
      r = $bits(hnd.dyn[i] & be);          // d19 handle-qualified select
      r = $bits(this.dyn[i] & be);         // d20 this-qualified select
      r = $bits(sp.hi & be);               // d21 member left
      r = $bits(spa[i].hi & be);           // d22 select-then-member
      r = $bits(v32[i +: 4] & be);         // d23 indexed part select
      r = $bits(v32[i -: 4] & be);         // d24
      r = $bits(dyn[i][0] & be);           // d25 select of select
      r = $bits($bits(dyn[i]) & 32'd1);    // d26 nested $bits left KEEP
      $display("%0d", r);
    endfunction
    function void mm();
      r = `BITSOF(dyn[i]);                 // d28 macro-formal argument
      r = `BITSOF(pk4[i]);                 // d29
      $display("%0d", r);
    endfunction
  endclass
endpackage
module vC;
  import pC2::*;
  initial begin CC c = new(); c.m(); c.mm(); end
endmodule
