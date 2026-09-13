// a6 — MODULE holder, base BAILS (member G is never assigned), one member 1024 bits.
// The BAIL twin of a5: same 1024-bit member, same override sites; the only
// change is the member `G` the function never assigns.
package p;
  typedef struct packed {
    int unsigned       A;
    int unsigned       B;
    logic [15:0][63:0] WIDE;
    int unsigned       G;
  } cfg_t;
  function automatic cfg_t mk(input bit e);
    cfg_t c;
    c.WIDE = {16{64'h0}};
    c.A = 32;
    c.B = e == 1'b1 ? (c.A / 16) : 1;
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
