// § defGenCaCommaListSpan283
module dut (input logic [3:0] x, output logic [3:0] a [2], output logic [3:0] b [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign a[i] = x, b[i] = ~x;
  end
endmodule
