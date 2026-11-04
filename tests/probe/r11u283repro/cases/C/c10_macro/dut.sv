// § defGenCaCommaListSpan283
`define TWO(p, q, v) assign p = v, q = ~v;
module dut (input logic [3:0] x, output logic [3:0] a, b);
  if (1) begin : g
    `TWO(a, b, x)
  end
endmodule
