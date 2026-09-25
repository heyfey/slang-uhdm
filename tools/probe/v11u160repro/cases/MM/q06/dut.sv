// § ppMacroBodyLines160
`define F `__LINE__
module top (output int y, output logic z);
  assign y = `F; assign z = 1'b1;
endmodule
