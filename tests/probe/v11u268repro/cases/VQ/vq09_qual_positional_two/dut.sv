// § pkgQualOvrPatInitSpan268
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t A = '{n: 3};
  localparam cfg_t B = '{n: 8};
endpackage
module leaf #(parameter p::cfg_t C = p::A) (output logic [31:0] o);
  assign o = C.n;
endmodule
module leaf2 #(parameter p::cfg_t C = p::A, parameter p::cfg_t E = p::A) (output logic [31:0] o);
  assign o = C.n + E.n;
endmodule
module top(output logic [31:0] o);
  leaf2 #(p::B, p::A) u (.o(o));
endmodule
