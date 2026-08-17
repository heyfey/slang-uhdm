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

module recv (itf.mp p[3]);
  localparam int AW = 5;
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  recv u (.p(arr));
endmodule
