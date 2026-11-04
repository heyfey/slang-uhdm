// § typeParamStructAtKeyword146
module top #(parameter type T = struct packed { logic [3:0] a; }, parameter type U = T) (input U i, output U o);
  assign o = i;
endmodule
