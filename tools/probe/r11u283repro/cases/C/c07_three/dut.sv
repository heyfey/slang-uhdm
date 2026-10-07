// § defGenCaCommaListSpan283
module dut (input logic [3:0] x, output logic [3:0] a, b, c);
  if (1) begin : g
    assign a = x, b = ~x, c = x ^ 4'h5;
  end
endmodule
