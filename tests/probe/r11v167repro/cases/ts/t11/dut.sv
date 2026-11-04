// § tpAnonStructLastParamUser167
module top #(parameter int W = 4) (input logic a, output logic [7:0] b);
  localparam int V = W * 2;
  localparam type it_t = struct packed {
    logic [V-1:0] x;
    logic [W:1] y;
  };
  localparam it_t I = '{x: 8'd1, y: 4'd2};
  assign b = a ? I.x : {4'd0, I.y};
endmodule
