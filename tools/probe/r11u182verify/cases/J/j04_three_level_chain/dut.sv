// § genElseIfGateTermPath171
module dut #(parameter int P = 3) (input a, b, output c);
  if (P == 1) begin
    assign c = a;
  end else if (P == 2) begin
    assign c = b;
  end else if (P == 3) begin
    nand g (c, a, b);
  end else begin
    assign c = 1'b0;
  end
endmodule
