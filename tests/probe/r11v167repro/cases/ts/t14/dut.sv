// § tpAnonStructLastParamUser167
module sub (input logic a, output logic [7:0] b);
  localparam type it_t = struct packed {
    logic [7:0] x;
    logic [7:0] y;
  };
  localparam it_t I = '{x: 8'd1, y: 8'd2};
  assign b = a ? I.x : I.y;
endmodule
module top (input logic a, output logic [7:0] b);
  if (1) begin : g
    sub u (.a(a), .b(b));
  end
endmodule
