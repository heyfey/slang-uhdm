// § tpAnonStructLastParamUser167
module top #(parameter type it_t = union packed { logic [7:0] x; logic [7:0] y; },
             parameter it_t U = 8'd5)
  (input logic a, output logic [7:0] b);
  assign b = a ? U.x : U.y;
endmodule
