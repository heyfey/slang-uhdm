// § pkgQualOvrPatGenLocalKeepsRef268v
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t A = '{n: 3};
  localparam cfg_t B = '{n: 8};
endpackage
module leaf #(parameter p::cfg_t C = p::A) (output logic [31:0] o);
  assign o = C.n;
endmodule
module top import p::*; #(parameter int K = 1) (output logic [31:0] o);
  case (K)
    1: begin : c1 localparam cfg_t G = '{n: 6}; leaf #(.C(G)) u (.o(o)); end
    default: begin : cd leaf #(.C(A)) u (.o(o)); end
  endcase
endmodule
