// § pkgQualOvrPatInitSpan268
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t A = '{n: 3};
  localparam cfg_t B = '{n: 8};
endpackage
module leaf #(parameter p::cfg_t C = p::A) (output logic [31:0] o);
  assign o = C.n;
endmodule
module top import p::*; #(parameter cfg_t P = '{n: 5}) (output logic [31:0] o);
  for (genvar i = 0; i < 1; i++) begin : g
    leaf #(.C(P)) u (.o(o));
  end
endmodule
