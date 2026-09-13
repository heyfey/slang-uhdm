// c2 — c1's leftover shapes with a PACKAGE holder (the landed reuse).
package p;
  typedef struct packed {
    int unsigned a;
    logic [63:0] b;
    bit          c;
    logic [31:0] d;
    logic [7:0]  e;
    logic [3:0]  f;
  } cfg_t;
  function automatic cfg_t build();
    cfg_t r;
    r.a = 32;
    r.b = 64'h1000;
    r.c = 1'b1;
    r.d = 32'd64;
    r.e = 8'o17;
    r.f = '1;
    return r;
  endfunction
  localparam cfg_t C = build();
endpackage

module top();
  child #(.W(p::C.a)) u1();
endmodule

module child #(parameter int unsigned W = 1) (); endmodule
