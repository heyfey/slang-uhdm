// § foldedBoundTsRefUnstored144
module dut #(parameter int P = 4) (input logic [3:0] a, output logic [3:0] y);
  if (P > 2) begin : g
    logic [P-1:0] t;
    assign t = a;
    assign y = t;
  end
endmodule
