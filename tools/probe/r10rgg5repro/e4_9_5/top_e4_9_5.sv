module top_e4_9_5;
  rggen_or_reducer #(.WIDTH(2), .N(9)) u00 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(5)) u01 (.i_data(), .o_result());
endmodule
