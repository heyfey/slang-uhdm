// § typeParamStructAtKeyword146
module top #(parameter type T = struct packed signed { logic [3:0] a; }) (input T i, output T o);
  assign o = i;
endmodule
