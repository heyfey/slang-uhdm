// § unitParamSizeDimWide432
parameter D = 'd3;
parameter E = 0;
parameter F = 2;
parameter int G = 4;
module m(input clk);
  logic [3:0] a [E+1];
  logic [3:0] b [D];
  logic [3:0] c [F];
  logic [3:0] d [$unit::G];
endmodule
