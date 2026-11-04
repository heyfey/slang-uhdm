// § defGenCaCommaListSpan283
module dut (input logic [3:0] x, output logic [3:0] a [2], b [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    if (i == 0) begin : h
      assign a[i] = x, b[i] = ~x;
    end else begin : k
      assign a[i] = ~x, b[i] = x;
    end
  end
endmodule
