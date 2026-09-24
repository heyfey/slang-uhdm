interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  wire  [AW-1:0] wn;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface
module recv #(
  parameter int AW = 8,
  parameter int BW = 32
)(
  itf.mp p[25]
);
endmodule
module top;
  itf #(8, 32, 64) arr[25]();
  recv #(.AW(16), .BW(32)) u (.p(arr));
endmodule
