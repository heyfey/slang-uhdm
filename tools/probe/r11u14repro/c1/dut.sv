// c1 — LITERAL leftover shapes, MODULE holder.
package p;
  typedef struct packed {
    int unsigned a;    // 32 : unsized decimal literal
    logic [63:0] b;    // 64 : HEX literal
    bit          c;    // 1  : BIN literal
    logic [31:0] d;    // 32 : sized DEC literal
    logic [7:0]  e;    // 8  : OCT literal
    logic [3:0]  f;    // 4  : unbased-unsized
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
endpackage

module top();
  localparam p::cfg_t C = p::build();
  child #(.W(C.a)) u1();
endmodule

module child #(parameter int unsigned W = 1) (); endmodule
