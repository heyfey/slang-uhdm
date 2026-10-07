// § defGenCaCommaListSpan283
module dut (input logic [3:0] x, output wire [3:0] a, b);
  if (1) begin : g
    assign (strong0, weak1) a = x, b = ~x;
  end
endmodule
