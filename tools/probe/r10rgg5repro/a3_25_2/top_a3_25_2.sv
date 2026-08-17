module top_a3_25_2;
  rggen_or_reducer #(.WIDTH(2), .N(25)) u00 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2)) u01 (.i_data(), .o_result());
endmodule
