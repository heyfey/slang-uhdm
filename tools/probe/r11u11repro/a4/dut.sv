// a4 — MODULE holder, base BAILS (member G is never assigned), members all <= 64 bits.
// The BAIL twin of a3: the only change is the member `G` the function never assigns.
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
    bit          F;
    int unsigned G;
  } cfg_t;
  function automatic cfg_t mk(input bit e);
    cfg_t c;
    c.A = 32;
    c.B = e == 1'b1 ? (c.A / 16) : 1;
    c.F = 1'b1;
    return c;
  endfunction
endpackage

module top();
  parameter p::cfg_t C = p::mk(1'b1);
  leaf #(.W(C.B)) u1();
  leaf #(.W(C.A)) u2();
endmodule

module leaf #(parameter int unsigned W = 2) ();
endmodule
