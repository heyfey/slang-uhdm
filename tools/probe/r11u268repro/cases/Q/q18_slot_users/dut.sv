// § pkgQualOvrPatInitSpan268
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t A = '{n: 3};
  localparam cfg_t B = '{n: 8};
  parameter cfg_t E = '{n: 12};
  typedef struct { int unsigned n; } ucfg_t;
  localparam ucfg_t U = '{n: 4};
endpackage
module leaf #(parameter p::cfg_t C = p::A) (output logic [31:0] o);
  assign o = C.n;
endmodule
module lbit #(parameter bit R = 0) (output logic o); assign o = R; endmodule
module lslot #(parameter p::cfg_t C = p::A) (output logic [31:0] o, output logic [15:0] r);
  assign o = {C.n[3:0], {(C.n % 4 + 1){1'b1}}};
  assign r = o[C.n[2:0] +: 4];
endmodule
module top(output logic [31:0] o, output logic [15:0] r); lslot #(.C(p::B)) u (.o(o), .r(r)); endmodule
