// § tpAnonStructLastParamUser167
module top (input logic a, output logic [7:0] b);
  localparam type it_t = struct packed {
    logic [7:0] x;
    logic [7:0] y;
  };
  localparam it_t I = '0;
  localparam it_t J = '{x: 8'd3, y: 8'd4};
  assign b = a ? I.x : J.y;
endmodule
