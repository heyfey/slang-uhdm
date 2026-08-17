module top_e1_2_4;
  rggen_or_reducer #(.WIDTH(2), .N(2)) u00 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(4)) u01 (.i_data(), .o_result());
endmodule
