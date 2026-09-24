module top(input logic a, output logic y, output logic z);
  assign y = a;
  // Synopsys translate_off
  assign z = ~a;
  // Synopsys translate_on
endmodule
