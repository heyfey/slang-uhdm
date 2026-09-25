// § sysArgUnaryWholeSpan140
module dut(input logic [3:0] a, input logic [7:0] p, input logic [7:0] q, output logic [7:0] y);
  assign y = ($signed(-a) > 0) ? p : q;
endmodule
