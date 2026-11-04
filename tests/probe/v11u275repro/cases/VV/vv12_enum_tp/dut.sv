// § tpTypedVarInitNameSpan275 — an enum type parameter with an initializer
package p;
  typedef enum logic [1:0] { A, B, C } e_t;
endpackage
module dut #(parameter type T = p::e_t) (output logic [1:0] o);
  T x = p::B;
  assign o = x;
endmodule
