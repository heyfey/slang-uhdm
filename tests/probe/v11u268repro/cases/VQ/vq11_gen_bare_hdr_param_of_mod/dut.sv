// § pkgQualOvrPatInitSpan268
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t A = '{n: 3};
  localparam cfg_t B = '{n: 8};
endpackage
module leaf #(parameter p::cfg_t C = p::A) (output logic [31:0] o);
  assign o = C.n;
endmodule
module top #(parameter p::cfg_t T = '{n: 4}) (output logic [31:0] o);
  if (1) begin : g
    leaf #(.C(T)) u (.o(o));
  end
endmodule
