// c9 — the BAIL twin of c1 (a member the builder never writes) plus the
// NEGATIVE CONTROLS: a non-function-built struct localparam and a plain
// integer localparam.  Both binaries must stay BYTE-IDENTICAL here.
package p;
  typedef struct packed {
    int unsigned a;
    logic [63:0] b;
    bit          c;
    logic [31:0] d;
    logic [7:0]  e;
    logic [3:0]  f;
    logic [7:0]  g;   // NEVER written by the builder
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
  localparam cfg_t G = '{a:1, b:2, c:1'b0, d:3, e:4, f:5, g:6};
  localparam int unsigned N = 7;
endpackage

module top();
  localparam p::cfg_t C = p::build();
  child #(.W(C.a)) u1();
  child #(.W(p::G.a)) u2();
  child #(.W(p::N))  u3();
endmodule

module child #(parameter int unsigned W = 1) (); endmodule
