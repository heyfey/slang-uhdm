// § typeParamStructAtKeyword146
module top #(parameter type T = struct packed { logic [3:0] a; logic b; }) (i, o);
  input T i;
  output T o;
  assign o = i;
endmodule
