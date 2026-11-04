// § portInitAssignAtHeader146
module sub (b);
  output reg b = 1;
endmodule
module dut(output o);
  sub u(.b(o));
endmodule
