module top_a6_25_20;
  rggen_or_reducer #(.WIDTH(2), .N(25)) u00 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(20)) u01 (.i_data(), .o_result());
endmodule
