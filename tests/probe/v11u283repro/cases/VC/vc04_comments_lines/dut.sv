// § defGenCaCommaListSpan283
module dut (input logic [3:0] x, output logic [3:0] a, b, c);
  if (1) begin : g
    assign a = x, // first
           b = ~x, /* second
           still */
           c = x ^ 4'h3;
  end
endmodule
