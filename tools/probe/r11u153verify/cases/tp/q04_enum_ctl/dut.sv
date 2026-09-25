// § typeParamStructAtKeyword146
module top #(parameter type T = enum logic [1:0] {A, B}) (input T i, output T o);
  assign o = i;
endmodule
