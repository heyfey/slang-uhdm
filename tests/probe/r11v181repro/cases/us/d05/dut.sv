// § bareDecUnderscoreDropped181 (v11u181 break: synthesizable selects and continuous assignments with separators, downstream-visible)
module top(input logic [31:0] a, output logic [31:0] y, output logic [7:0] z);
  assign y[15:8] = 2_0;
  assign y[7:0] = a[1_5:8] + 1_0;
  assign y[31:16] = a[3_1] ? 1_000 : 2_000;
  assign z = a[2_0 +: 8];
endmodule
