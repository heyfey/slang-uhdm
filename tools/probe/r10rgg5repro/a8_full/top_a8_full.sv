module top_a8_full;
  rggen_or_reducer #(.WIDTH(2), .N(25)) u00 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2)) u01 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2)) u02 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2)) u03 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2)) u04 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2)) u05 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2)) u06 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2)) u07 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2)) u08 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2)) u09 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2)) u10 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2)) u11 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(20)) u12 (.i_data(), .o_result());
endmodule
