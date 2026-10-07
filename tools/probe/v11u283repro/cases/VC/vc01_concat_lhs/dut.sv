// § defGenCaCommaListSpan283
module dut (input logic [3:0] x, output logic [1:0] a, b, output logic [3:0] c);
  if (1) begin : g
    assign {a, b} = x, c = ~x;
  end
endmodule
