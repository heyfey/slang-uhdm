// b6 — NO import at all: every read is fully qualified.  There is no
// materialized import copy, so R3 has nothing to key on and only R1/R2 fire.
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
    logic [15:0][63:0] WIDE;
  } cfg_t;
  function automatic cfg_t mk(input bit e);
    cfg_t c;
    c.WIDE = {16{64'h0}};
    c.A = 32;
    c.B = e == 1'b1 ? (c.A / 16) : 1;
    return c;
  endfunction
  localparam cfg_t C = mk(1'b1);
endpackage

module top ();
  parameter p::cfg_t D = p::C;
  holder #(.H(p::C)) u1();
  holder #(.H(D))    u2();
endmodule

module holder #(parameter p::cfg_t H = '0) (); endmodule
