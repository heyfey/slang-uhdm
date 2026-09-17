// v3 — the `default:` faces at the import-copy face (r11u49: golden flattens
// both `'{default: N}` and `'{A:1, default: N}` in the package listing).
package p3d;
  typedef struct { int unsigned a; int unsigned b; int unsigned c; } d3_t;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } dp_t;
  localparam d3_t UDEF = '{default: 7};
  localparam d3_t UMIX = '{a: 1, default: 9};
  localparam dp_t PDEF = '{default: 8'd7};
  localparam dp_t PMIX = '{a: 8'd1, default: 8'd9};
  function automatic int unsigned pf3();       // never called
    return UDEF.a + UMIX.b + PDEF.a + PMIX.b;
  endfunction
endpackage

module v3q import p3d::*; (input logic clk, output logic [7:0] d);
  assign d = '0;
endmodule

module v3top(input logic clk);
  logic [7:0] dd;
  v3q u_q (.clk(clk), .d(dd));
endmodule
