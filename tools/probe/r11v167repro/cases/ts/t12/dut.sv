// § tpAnonStructLastParamUser167
module top (input logic a, output logic [7:0] b);
  localparam type it_t = struct packed {
    logic [7:0] x;
    logic [7:0] y;
  };
  localparam it_t I [2] = '{'{x: 8'd1, y: 8'd2}, '{x: 8'd3, y: 8'd4}};
  assign b = a ? I[0].x : I[1].y;
endmodule
