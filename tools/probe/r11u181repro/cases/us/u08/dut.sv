// § bareDecUnderscoreDropped181 — control: unsized based literals with and without separators onto a 16-bit net, and a range bound with separators
module top(output wire [15:0] a, b, c, d, output logic [1_5:0] q);
  assign a = 'h10;
  assign b = 'h1_0;
  assign c = 'd1_0 + 1;
  assign d = 'b1_0;
  assign q = '0;
endmodule
