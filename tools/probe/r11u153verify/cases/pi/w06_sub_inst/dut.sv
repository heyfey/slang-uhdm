// § portInitAssignAtHeader146
module sub (q);
  output reg [1:0] q = 2'b10;
endmodule
module dut(output logic [1:0] o);
  sub s(o);
endmodule
