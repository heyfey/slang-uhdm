// § defGenCaCommaListSpan283
`define TWO(p, q) assign p = x, q = ~x;
module dut (input logic [3:0] x, output logic [3:0] a, b);
  if (1) begin : g
    `TWO(a, b)
  end
endmodule
