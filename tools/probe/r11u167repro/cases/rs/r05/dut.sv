// § tpAnonStructLastParamUser167
module top #(parameter type it_t = struct packed { logic [7:0] x; logic [7:0] y; })
  (input logic a, output logic [7:0] b);
  localparam it_t I = '{x: 8'd1, y: 8'd2};
  assign b = a ? I.x : I.y;
endmodule
