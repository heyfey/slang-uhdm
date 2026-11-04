// § defGenCaCommaListSpan283
module dut (input logic [3:0] x, output logic [3:0] a, b);
  if (1) begin : g
    assign a = x,   // first
           /* second */ b = ~x;
  end
endmodule
