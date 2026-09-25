// § tpAnonStructLastParamUser167
module top #(parameter type it_t = struct packed { logic [7:0] x; logic [7:0] y; },
             parameter it_t P = '{x: 8'd1, y: 8'd2})
  (input logic a, output logic [7:0] b);
  localparam it_t Q = '{x: 8'd3, y: 8'd4};
  assign b = a ? P.x : Q.y;
endmodule
