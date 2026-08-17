module top;
  orv #(.WIDTH(2), .N(20)) u0 (.i_data(), .o_result());
  orv #(.WIDTH(2), .N(20)) u1 (.i_data(), .o_result());
endmodule
