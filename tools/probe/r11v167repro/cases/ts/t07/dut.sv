// § tpAnonStructLastParamUser167
module top (input logic a, output logic [7:0] b);
  localparam type it_t = struct packed {
    logic [7:0] x;
    logic [7:0] y;
  };
  localparam type jt_t = struct packed {
    logic [3:0] p;
    logic [3:0] q;
  };
  localparam jt_t K = '{p: 4'd1, q: 4'd2};
  localparam it_t I = '{x: 8'd1, y: 8'd2};
  assign b = a ? I.x : {K.p, K.q};
endmodule
