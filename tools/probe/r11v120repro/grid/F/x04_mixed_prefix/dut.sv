module top(input logic a, output logic y, output logic z);
  assign y = a;
  // synopsys translate_off
  initial $display("sim");
  // pragma translate_on
  assign z = ~a;
endmodule
