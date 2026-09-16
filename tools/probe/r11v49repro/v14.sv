// v11u49 arm v14 — LAW A robustness: exotic member kinds and a cross-package
// element value, all in one UNPACKED package struct, read scoped.
package base;
  localparam int unsigned K = 32'd77;
endpackage
package p;
  import base::*;
  typedef struct { real r; logic [7:0] a; } ur_t;
  typedef struct { string s; logic [7:0] a; } us_t;
  typedef struct { logic [31:0] k; logic [7:0] a; } uk_t;
  localparam ur_t UR = '{r:1.5, a:8'd1};
  localparam us_t US = '{s:"hi", a:8'd2};
  localparam uk_t UK = '{k:base::K, a:8'd3};
endpackage
module v14 (output logic [31:0] o);
  assign o = p::UR.a + p::US.a + p::UK.k;
endmodule
