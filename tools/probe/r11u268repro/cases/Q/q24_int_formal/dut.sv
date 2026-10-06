// § pkgQualOvrPatInitSpan268
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t A = '{n: 3};
  localparam cfg_t B = '{n: 8};
  parameter cfg_t E = '{n: 12};
  typedef struct { int unsigned n; } ucfg_t;
  localparam ucfg_t U = '{n: 4};
endpackage
module leaf #(parameter p::cfg_t C = p::A) (output logic [31:0] o);
  assign o = C.n;
endmodule
module lbit #(parameter bit R = 0) (output logic o); assign o = R; endmodule
module lint #(parameter int R = 0) (output logic [31:0] o); assign o = R; endmodule
module top import p::*; (output logic [31:0] o1, o2);
  lint #(.R(p::B)) u (.o(o1));
  if (1) begin : g lint #(.R(B)) v (.o(o2)); end
endmodule
