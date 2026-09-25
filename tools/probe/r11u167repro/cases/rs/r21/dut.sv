// § tpAnonStructLastParamUser167
`define MKP(n, v) localparam it_t n = '{x: v, y: v};
module top (input logic a, output logic [7:0] b);
  localparam type it_t = struct packed {
    logic [7:0] x;
    logic [7:0] y;
  };
  `MKP(I, 8'd3)
  assign b = a ? I.x : I.y;
endmodule
