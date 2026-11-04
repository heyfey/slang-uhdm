// § pkgQualOvrPatInitSpan268
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t A = '{n: 3};
  localparam cfg_t B = '{n: 8};
endpackage
module leaf #(parameter p::cfg_t C = p::A) (output logic [31:0] o);
  assign o = C.n;
endmodule
module leaf3 #(parameter p::cfg_t C = p::A) (output logic [C.n-1:0] o);
  assign o = {C.n{1'b1}};
endmodule
module top(output logic [7:0] o);
  leaf3 #(.C(p::B)) u (.o(o));
endmodule
