// § pkgEnumParamFold401
package p1;
  typedef enum bit [6:0] { A, B, C } e_t;
endpackage
module top #(parameter p1::e_t m = p1::B) (output logic [6:0] o);
  assign o = m;
endmodule
