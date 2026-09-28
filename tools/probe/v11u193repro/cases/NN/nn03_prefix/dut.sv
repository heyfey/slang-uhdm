// § nestedDefChainName193
module sub ();
  logic inner_x;
  logic inner;
  module inner_m (output logic q);
    logic inner_x;
    assign inner_x = 1'b1;
    assign q = inner_x;
  endmodule
  assign inner_x = 1'b0;
  assign inner = inner_x;
endmodule
module dut (output logic o);
  sub u_s ();
  assign o = 1'b0;
endmodule
