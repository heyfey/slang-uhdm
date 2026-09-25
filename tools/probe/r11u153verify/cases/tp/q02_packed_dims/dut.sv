// § typeParamStructAtKeyword146
module top #(parameter type T = struct packed { logic [3:0] a; logic b; } [1:0]) (input T i, output T o);
  assign o = i;
endmodule
