module top_e3_5_9;
  rggen_or_reducer #(.WIDTH(2), .N(5)) u00 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(9)) u01 (.i_data(), .o_result());
endmodule
