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
module mid #(parameter p::cfg_t C = p::A) (output logic [31:0] o);
  leaf #(.C(C)) l (.o(o));
endmodule
module mid2 #(parameter p::cfg_t C = p::A) (output logic [31:0] o);
  if (1) begin : g
    mid #(.C(C)) m (.o(o));
  end
endmodule
module top(output logic [31:0] o1, o2);
  mid #(.C(p::B)) m1 (.o(o1));
  mid2 #(.C(p::B)) m2 (.o(o2));
endmodule
