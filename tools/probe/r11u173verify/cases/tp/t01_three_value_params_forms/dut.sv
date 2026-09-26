// § tpAnonStructLastParamUser167 § tpAnonStructCopySpanAtKeyword167 — three value parameters of the type: '0, a pattern, a typed pattern
module top (input logic a, output logic [3:0] b);
  localparam type it_t = struct packed {
    logic [3:0] x;
    logic [3:0] y;
  };
  localparam it_t P0 = '0;
  localparam it_t P1 = '{x: 4'd1, y: 4'd2};
  localparam it_t P2 = it_t'{x: 4'd3, y: 4'd5};
  assign b = a ? P1.x : (P2.y ^ P0.x);
endmodule
