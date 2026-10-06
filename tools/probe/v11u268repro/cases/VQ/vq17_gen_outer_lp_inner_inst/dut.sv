// § pkgQualOvrPatGenLocalKeepsRef268v
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t A = '{n: 3};
  localparam cfg_t B = '{n: 8};
endpackage
module leaf #(parameter p::cfg_t C = p::A) (output logic [31:0] o);
  assign o = C.n;
endmodule
module top import p::*; (output logic [31:0] o);
  if (1) begin : g
    localparam cfg_t G = '{n: 6};
    if (1) begin : h
      leaf #(.C(G)) u (.o(o));
    end
  end
endmodule
