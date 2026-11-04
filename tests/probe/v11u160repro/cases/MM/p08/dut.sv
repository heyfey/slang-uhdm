// § ppMacroBodyLines160
`define LN `__LINE__
module top (output int y, output logic z);
  assign y = `__LINE__; assign z = 1'b0;
endmodule
