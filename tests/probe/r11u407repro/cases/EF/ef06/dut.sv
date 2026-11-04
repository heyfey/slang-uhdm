// § pkgRetEnumOperandFold407
package p;
  typedef enum logic [7:0] {
    A = 'b000_00000,
    B = 'b001_00000
  } t_e;
endpackage
module top(input p::t_e i, output logic o, output logic q);
  import p::*;
  assign o = (i != A);
  always_comb q = (i == B);
endmodule
