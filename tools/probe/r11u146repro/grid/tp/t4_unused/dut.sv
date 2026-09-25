// § typeParamStructAtKeyword146
module top #(parameter type T = struct packed { logic [3:0] a; }) (input logic i, output logic o);
  assign o = i;
endmodule
