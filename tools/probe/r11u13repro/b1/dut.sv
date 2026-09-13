// b1 — PACKAGE base, ASSEMBLES, WILDCARD import.  All three sites at once:
//   R1  `parameter cfg_t D = p::C`   -- the default that reads the base WHOLE
//   R2  `holder #(.H(p::C))`         -- the override actual, a bare reference
//   R2' `holder #(.H(D))`            -- the same, off the R1-chained parameter
//   R3  the materialized import copies work@top.C / work@holder.C
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

module top
  import p::*;
();
  parameter cfg_t D = p::C;           // R1
  holder #(.H(p::C)) u1();            // R2
  holder #(.H(D))    u2();            // R2'
endmodule

module holder
  import p::*;
#(parameter cfg_t H = '0) ();
endmodule
