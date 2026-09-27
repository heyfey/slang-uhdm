// § bareDecUnderscoreDropped181 — an unsized decimal with underscores onto a select and onto a whole net (v11u182 g04's shape)
module top(output wire [15:0] c, output wire [15:0] d);
  assign c[15:8] = 1_0;
  assign c[7:0] = 2_5;
  assign d = 1_000;
endmodule
