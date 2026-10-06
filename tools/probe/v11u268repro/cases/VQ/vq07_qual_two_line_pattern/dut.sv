// § pkgQualOvrPatInitSpan268
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t A = '{n: 3};
  localparam cfg_t B = '{n: 8};
endpackage
module leaf #(parameter p::cfg_t C = p::A) (output logic [31:0] o);
  assign o = C.n;
endmodule
package q;
  localparam p::cfg_t M = '{
     n: 11};
endpackage
module top(output logic [31:0] o);
  leaf #(.C(q::M)) u (.o(o));
endmodule
