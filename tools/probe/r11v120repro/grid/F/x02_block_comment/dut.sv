module top(input logic a, output logic y, output logic z);
  assign y = a;
  /* synopsys translate_off */
  assign z = ~a;
  /* synopsys translate_on */
endmodule
