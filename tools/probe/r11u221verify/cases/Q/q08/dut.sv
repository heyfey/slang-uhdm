// § genScopeRangeQueryFold216 + § ndaRangeQueryFold216 — a child with a W-1 port and a localparam bound read in a gen-if and a net initializer, instantiated twice under different overrides
module sub #(parameter int W = 2) (input logic [W-1:0] x, output logic [7:0] y, output logic [7:0] z);
  localparam int LW = W + 1;
  logic [LW:1] lv;
  wire [7:0] nz = $low(x);
  if (W > 1) begin : g
    assign y = $high(lv);
  end
  assign z = nz;
endmodule
module dut (input logic [7:0] a, output logic [7:0] y1, output logic [7:0] y2, output logic [7:0] z1, output logic [7:0] z2);
  sub #(.W(3)) u1 (.x(a[2:0]), .y(y1), .z(z1));
  sub #(.W(7)) u2 (.x(a[6:0]), .y(y2), .z(z2));
endmodule
