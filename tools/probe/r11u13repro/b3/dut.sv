// b3 — MODULE-held base (§ modStructFuncAssembleBin's holder), assembled.
// The typedef lives in a package so the child's formal can be typed, but the
// BASE localparam is module-held: only R1/R2 can fire, R3 has no import copy
// of a family localparam to key on.
package p;
  typedef struct packed { int unsigned A; int unsigned B; } cfg_t;
endpackage

module top ();
  function automatic p::cfg_t mk(input bit e);
    p::cfg_t c;
    c.A = 32;
    c.B = e == 1'b1 ? (c.A / 16) : 1;
    return c;
  endfunction
  localparam p::cfg_t C = mk(1'b1);
  parameter  p::cfg_t D = C;          // R1 off a MODULE-held base
  holder #(.H(C)) u1();               // R2
  holder #(.H(D)) u2();               // R2'
endmodule

module holder #(parameter p::cfg_t H = '0) (); endmodule
