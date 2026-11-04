module top;
  orv #(.WIDTH(2), .N(25)) u0 (.i_data(), .o_result());
  orv #(.WIDTH(2), .N(25)) u1 (.i_data(), .o_result());
endmodule
