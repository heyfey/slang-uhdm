// § portInitAssignAtHeader146
module dut(a,
           b, c);
  input a;
  output reg b = 1'b1;
  output reg [3:0] c = 4'h5;
endmodule
