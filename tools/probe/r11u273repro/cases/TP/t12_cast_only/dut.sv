// § typeParamStructLastNetParent273
module top #(parameter type idx_t = struct packed { logic p; logic q; }) (input logic a, output logic [1:0] y);
  assign y = idx_t'(a);
endmodule
