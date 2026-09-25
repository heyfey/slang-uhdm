// § sysArgUnaryWholeSpan140
`define NEGBITS(v) $bits(~v)
module dut(input logic [5:0] a, output int y);
  assign y = `NEGBITS(a);
endmodule
