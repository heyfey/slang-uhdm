// § defGenCaCommaListSpan283
module dut #(parameter int P = 0) (input logic [3:0] x, output logic [3:0] a, b);
  if (P == 1) begin : g1
    assign a = x;
    assign b = x;
  end else begin : g2
    assign a = ~x, b = x;
  end
endmodule
