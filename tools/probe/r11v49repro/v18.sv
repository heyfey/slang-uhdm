// v11u49 arm v18 — LAW A x parameter OVERRIDE: an unpacked struct package
// parameter used as the default and as the actual of a child's formal.
package p;
  typedef struct { logic [7:0] a; logic [7:0] b; } ub_t;
  localparam ub_t DEF = '{a:8'd1, b:8'd2};
  localparam ub_t OVR = '{a:8'd3, b:8'd4};
  localparam int  USE = DEF.a + OVR.a;
endpackage
module child #(parameter p::ub_t CFG = p::DEF) (output logic [31:0] o);
  assign o = CFG.a + CFG.b;
endmodule
module v18 (output logic [31:0] o);
  logic [31:0] w0, w1;
  child            c0 (.o(w0));
  child #(p::OVR)  c1 (.o(w1));
  assign o = w0 + w1 + p::USE;
endmodule
