module top_b4_6x2;
  rggen_or_reducer #(.WIDTH(2), .N(6)) u00 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(6)) u01 (.i_data(), .o_result());
endmodule
