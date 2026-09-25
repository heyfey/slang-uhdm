// § tpAnonStructCopySpanAtKeyword167
module top (input logic a, output logic [7:0] b);
  localparam type it_t = struct packed {
    logic [7:0] x;
    logic [7:0] y;
  };
  localparam it_t I = '{x: 8'd1, y: 8'd2};
  it_t v;
  assign v = I;
  assign b = a ? v.x : v.y;
endmodule
