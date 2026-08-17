module top_efull;
  rggen_or_reducer #(.WIDTH(2), .N(25)) u0 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2))  r1 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2))  r2 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2))  r3 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2))  r4 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2))  r5 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2))  r6 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2))  r7 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2))  r8 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2))  r9 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2))  ra (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(2))  rb (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(20)) u1 (.i_data(), .o_result());
endmodule
