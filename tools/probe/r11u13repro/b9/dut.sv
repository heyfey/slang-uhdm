// b9 — THE VIEW MATRIX.  One importing module instantiated TWICE: the DEF
// module listing (uhdmallModules) keeps the assembler's bare bits and EVERY
// elaborated instance copy carries the `<w>'b` prefix.
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
  } cfg_t;
  function automatic cfg_t mk(input bit e);
    cfg_t c;
    c.A = 32;
    c.B = e == 1'b1 ? (c.A / 16) : 1;
    return c;
  endfunction
  localparam cfg_t C = mk(1'b1);
endpackage

module top
  import p::*;
();
  parameter cfg_t D = p::C;
  kid u1();
  kid u2();
endmodule

module kid
  import p::*;
();
  parameter cfg_t K = C;
endmodule
