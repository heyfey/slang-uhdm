// § pkgQualOvrPatGenLocalKeepsRef268v
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t A = '{n: 3};
  localparam cfg_t B = '{n: 8};
endpackage
module leaf #(parameter p::cfg_t C = p::A) (output logic [31:0] o);
  assign o = C.n;
endmodule
module top import p::*; (output logic [31:0] o [3]);
  for (genvar i = 0; i < 3; i++) begin : g
    localparam cfg_t L = '{n: i};
    leaf #(.C(L)) u (.o(o[i]));
  end
endmodule
