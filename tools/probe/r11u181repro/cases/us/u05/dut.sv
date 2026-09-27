// § bareDecUnderscoreDropped181 — underscores in select indices and part-select bounds
module top(input logic [31:0] din, output logic y, output logic [3:0] z);
  assign y = din[1_0];
  assign z = din[1_5:1_2];
endmodule
