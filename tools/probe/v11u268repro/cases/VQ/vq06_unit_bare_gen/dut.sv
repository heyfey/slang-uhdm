// § pkgQualOvrPatInitSpan268
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t A = '{n: 3};
  localparam cfg_t B = '{n: 8};
endpackage
module leaf #(parameter p::cfg_t C = p::A) (output logic [31:0] o);
  assign o = C.n;
endmodule
localparam p::cfg_t UB = '{n: 7};
module top(output logic [31:0] o);
  if (1) begin : g
    leaf #(.C(UB)) u (.o(o));
  end
endmodule
