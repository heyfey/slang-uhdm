// § tpAnonStructLastParamUser167
module top (input logic a, output logic [7:0] b);
  localparam type it_t = struct packed {
    logic [7:0] x;
    logic [7:0] y;
  };
  localparam it_t I = '{x: 8'd1, y: 8'd2};
  if (1) begin : g
    localparam it_t K = '{x: 8'd7, y: 8'd8};
    assign b = a ? I.x : K.y;
  end
endmodule
