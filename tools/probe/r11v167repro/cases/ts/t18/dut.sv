// § tpAnonStructLastParamUser167
module top #(parameter int W = 8) (input logic a, output logic [7:0] b);
  localparam type it_t = struct packed {
    logic [W-1:0] x;
    logic [W-1:0] y;
  };
  localparam it_t I = '{x: 8'd1, y: 8'd2};
  localparam int K = W + 1;
  localparam it_t J = '{x: K[7:0], y: 8'd4};
  assign b = a ? I.x : J.x;
endmodule
