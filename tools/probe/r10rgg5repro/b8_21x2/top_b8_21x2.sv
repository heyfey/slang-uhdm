module top_b8_21x2;
  rggen_or_reducer #(.WIDTH(2), .N(21)) u00 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(21)) u01 (.i_data(), .o_result());
endmodule
