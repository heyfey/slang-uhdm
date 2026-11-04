// § pkgQualOvrPatInitSpan268
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t A = '{n: 3};
  localparam cfg_t B = '{n: 8};
endpackage
module leaf #(parameter p::cfg_t C = p::A) (output logic [31:0] o);
  assign o = C.n;
endmodule
module top(output logic [31:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    if (1) begin : h
      leaf #(.C(p::B)) u (.o(o[i]));
    end
  end
endmodule
