module top_a7_20x2;
  rggen_or_reducer #(.WIDTH(2), .N(20)) u00 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(20)) u01 (.i_data(), .o_result());
endmodule
