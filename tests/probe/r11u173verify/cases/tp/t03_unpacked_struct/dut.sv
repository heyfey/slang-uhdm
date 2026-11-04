// § tpAnonStructLastParamUser167 § tpAnonStructCopySpanAtKeyword167 — an UNPACKED anonymous struct type parameter
module top (input logic a, output logic [3:0] b);
  localparam type it_t = struct {
    logic [3:0] x;
    logic [3:0] y;
  };
  localparam it_t I = '{x: 4'd5, y: 4'd6};
  assign b = a ? I.x : I.y;
endmodule
