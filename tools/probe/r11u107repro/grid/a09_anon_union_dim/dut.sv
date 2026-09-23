module dut(input logic [3:0] i, output logic [3:0] o);
  union packed { logic [1:0] a; logic [1:0] b; } [1:0] x;
  assign x = i;
  assign o = x;
endmodule
