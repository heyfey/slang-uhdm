module top_b2_4x2;
  rggen_or_reducer #(.WIDTH(2), .N(4)) u00 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(4)) u01 (.i_data(), .o_result());
endmodule
