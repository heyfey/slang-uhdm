module top(input logic a, output logic y, output logic z);
  assign y = a;
  // pragma translate_off, begin sim
  assign z = ~a;
  // pragma translate_on
endmodule
