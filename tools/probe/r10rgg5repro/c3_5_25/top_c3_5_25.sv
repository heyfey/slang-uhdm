module top_c3_5_25;
  rggen_or_reducer #(.WIDTH(2), .N(5)) u00 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(25)) u01 (.i_data(), .o_result());
endmodule
