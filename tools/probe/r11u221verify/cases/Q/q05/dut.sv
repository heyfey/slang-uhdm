// § genScopeRangeQueryFold216 + § ndaRangeQueryFold216 — sized and based bounds (hex, binary, octal, sized decimal) on nets queried in a gen-for and in net initializers (confirm: golden keeps HEX / BIN on the bound)
module dut (output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3, output logic [7:0] o4);
  logic [4'hA:4'b0010] a;
  logic [3'o6:2'd1] b;
  wire [7:0] n1 = $high(a);
  wire [7:0] n2 = $low(b);
  for (genvar i = 0; i < 1; i++) begin : g
    assign o3 = $left(a);
    assign o4 = $right(b);
  end
  assign o1 = n1;
  assign o2 = n2;
endmodule
