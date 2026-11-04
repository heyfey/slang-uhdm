// § boundLitWrittenDigits172
module dut #(parameter int P = 1) (input logic [7:0] a, output logic [7:0] o);
  if (P == 1) begin : g
    logic [07:00] w;
    assign w = a;
    assign o = w;
  end else begin : h
    assign o = '0;
  end
  for (genvar i = 0; i < 2; i++) begin : l
    logic [03:0] v;
    assign v = a[i*4 +: 4];
  end
endmodule
