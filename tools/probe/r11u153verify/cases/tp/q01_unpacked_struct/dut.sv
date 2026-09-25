// § typeParamStructAtKeyword146
module top #(parameter type T = struct { int a; logic b; }) (input logic i, output logic o);
  T v;
  assign o = i;
endmodule
