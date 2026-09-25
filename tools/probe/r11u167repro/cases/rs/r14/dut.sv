// § tpAnonStructLastParamUser167
module top #(parameter int W = 8) (input logic a, output logic [W-1:0] b);
  localparam type it_t = struct packed {
    logic [W-1:0] x;
    logic [W-1:0] y;
  };
  it_t v;
  assign v = '{x: W'(1), y: W'(2)};
  assign b = a ? v.x : v.y;
endmodule
