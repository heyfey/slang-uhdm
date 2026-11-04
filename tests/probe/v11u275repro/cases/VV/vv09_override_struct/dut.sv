// § tpTypedVarInitNameSpan275 — a child type parameter overridden by a package struct
package p;
  typedef struct packed { logic [3:0] a; } s_t;
endpackage
module child #(parameter type T = logic [3:0]) (output logic [3:0] o);
  T x = 4'h7;
  assign o = x;
endmodule
module dut (output logic [3:0] o);
  child #(.T(p::s_t)) u (.o(o));
endmodule
