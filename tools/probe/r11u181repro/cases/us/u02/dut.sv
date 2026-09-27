// § bareDecUnderscoreDropped181 — based and sized literals with underscores in continuous assignments (control: no r11u181 law fires)
module top(output wire [15:0] a, b, c, d, e);
  assign a = 16'h1_F;
  assign b = 16'b1010_1010;
  assign c = 'd1_0;
  assign d = 16'd1_000;
  assign e = 'h1_0;
endmodule
