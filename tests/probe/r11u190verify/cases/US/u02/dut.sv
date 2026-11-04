// § bareDecUnderscoreDropped181 (r11u190: a sized decimal, a negative, a comparison and a replication count with separators)
module top(input logic [31:0] a, output logic [31:0] y, output logic c, output logic [15:0] z);
  assign y = a + 32'd1_000 - 1_0;
  assign c = (a == -1_0) || (a > 1_000);
  assign z = {1_6{a[0]}};
endmodule
