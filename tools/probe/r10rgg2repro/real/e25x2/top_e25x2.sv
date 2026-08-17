module top_e25x2;
  rggen_or_reducer #(.WIDTH(2), .N(25)) u0 (.i_data(), .o_result());
  rggen_or_reducer #(.WIDTH(2), .N(25)) u1 (.i_data(), .o_result());
endmodule
