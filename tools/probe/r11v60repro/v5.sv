// v5 — the NON-INTEGRAL member fences at the import-copy face, unpacked:
// string, an unpacked ARRAY member, and a real (the g5 control repeated in a
// package whose select is a typedef dim rather than a dead function).
package p5n;
  typedef struct { string s;        int unsigned a; } ss_t;
  typedef struct { logic [7:0] a;   logic [15:0] b [3]; } ua_t;
  typedef struct { int unsigned a;  int unsigned b; } ok_t;
  localparam ss_t SSTR = '{s: "x", a: 4};
  localparam ua_t SARR = '{a: 8'd1, b: '{16'd1, 16'd2, 16'd3}};
  localparam ok_t SOK  = '{a: 4, b: 8};
  typedef logic [SOK.a-1:0] v5_t;
  function automatic int unsigned pf5n();   // never called
    return SSTR.a + SARR.a + SOK.a;
  endfunction
endpackage

module v5q import p5n::*; (input logic clk);
  v5_t d;
  assign d = '0;
endmodule

module v5top(input logic clk);
  v5q u_q (.clk(clk));
endmodule
