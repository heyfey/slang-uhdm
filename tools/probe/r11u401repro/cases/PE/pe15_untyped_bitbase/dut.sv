// § pkgEnumUntypedParamFold401
package p1;
  typedef enum bit [6:0] { A, B, C } e_t;
endpackage
package p2;
  localparam m = p1::A;
  parameter int k = 4;
endpackage
module top; endmodule
