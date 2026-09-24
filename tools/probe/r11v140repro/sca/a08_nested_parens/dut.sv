// § sysArgUnaryWholeSpan140
module top(input logic [7:0] a, output logic [7:0] o, output logic [7:0] o2);
  assign o = $signed(-(a));
  assign o2 = $unsigned(~(~a));
endmodule
