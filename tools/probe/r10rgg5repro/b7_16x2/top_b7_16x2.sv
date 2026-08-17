module top_b7_16x2;
  rggen_or_reducer #(.WIDTH(2), .N(16)) u00 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(16)) u01 (.i_data(), .o_result());
endmodule
