// § lineDirectiveIgnored416
module sub(input logic i, output logic o);
  assign o = i;
endmodule
module top(input logic x, output logic y);
`line 200 "dut.sv" 1
  sub u (.i(x), .o(y));
endmodule
