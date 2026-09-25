// § tpAnonStructLastParamUser167
module top (input logic a, output logic [7:0] b);
  localparam type it_t = struct packed {
    logic [3:0] x;
    logic [3:0] y;
  };
  localparam it_t [1:0] I = '{'{x: 4'd1, y: 4'd2}, '{x: 4'd3, y: 4'd4}};
  assign b = a ? I[0] : I[1];
endmodule
