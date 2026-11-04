// § typeParamStructAtKeyword146
module top #(parameter type T = union packed { logic [3:0] a; logic [3:0] b; }) (input T i, output T o);
  assign o = i;
endmodule
