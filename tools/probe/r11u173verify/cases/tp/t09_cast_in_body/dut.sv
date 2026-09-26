// § tpAnonStructLastParamUser167 § tpAnonStructCopySpanAtKeyword167 — the type named again by a cast in the body (the token count must abstain)
module top (input logic [7:0] a, output logic [3:0] b);
  localparam type it_t = struct packed {
    logic [3:0] x;
    logic [3:0] y;
  };
  localparam it_t I = '{x: 4'd1, y: 4'd2};
  assign b = I.y ^ 4'(it_t'(a));
endmodule
