// § nestedDefChainName193
module sub (output logic [3:0] y);
  module innermod (output logic [3:0] r);
    assign r = 4'd2;
  endmodule
  innermod u_i (.r(y));
endmodule
module dut (output logic [3:0] o);
  sub u_s (.y(o));
endmodule
