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
  parameter int AW = 5
)(
  itf.mp p
);
endmodule

module top;
  itf #(8, 32, 64) inst();
  recv u (inst);
endmodule
