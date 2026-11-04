// § defGenCaCommaListSpan283
module dut #(parameter bit P = 1) (input logic [3:0] x, output logic [3:0] a, b);
  if (P) assign a = x, b = ~x;
  else assign a = ~x, b = x;
endmodule
