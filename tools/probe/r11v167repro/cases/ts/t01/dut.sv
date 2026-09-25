// § tpAnonStructLastParamUser167
module sub #(parameter int W = 8) (input logic a, output logic [W-1:0] b);
  localparam type it_t = struct packed {
    logic [W-1:0] x;
    logic [W-1:0] y;
  };
  localparam it_t I = '{x: W'(1), y: W'(2)};
  assign b = a ? I.x : I.y;
endmodule
module top (input logic a, output logic [7:0] b, output logic [3:0] c);
  sub u1 (.a(a), .b(b));
  sub #(.W(4)) u2 (.a(a), .b(c));
endmodule
