// § tpAnonStructLastParamUser167
module top #(parameter int W = 8) (input logic a, output logic [W-1:0] b);
  localparam type it_t = struct packed {
    logic [W-1:0] x;
    logic [W-1:0] y;
  };
  assign b = {W{a}};
endmodule
