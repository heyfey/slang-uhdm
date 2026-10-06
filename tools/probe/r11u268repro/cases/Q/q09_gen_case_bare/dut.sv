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
module top import p::*; #(parameter int K = 1) (output logic [31:0] o);
  case (K)
    1: begin : c1 leaf #(.C(B)) u (.o(o)); end
    default: begin : cd leaf #(.C(A)) u (.o(o)); end
  endcase
endmodule
