module top_b6_13x2;
  rggen_or_reducer #(.WIDTH(2), .N(13)) u00 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(13)) u01 (.i_data(), .o_result());
endmodule
