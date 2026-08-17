module top_c1_2_2_25;
  rggen_or_reducer #(.WIDTH(2), .N(2)) u00 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2)) u01 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(25)) u02 (.i_data(), .o_result());
endmodule
