// § lineDirectiveIgnored416
module sub(input logic i, output logic o);
  assign o = i;
endmodule
`line 500 "dut.sv" 1
module top(input logic x, output logic y);
  sub u (.i(x), .o(y));
endmodule
