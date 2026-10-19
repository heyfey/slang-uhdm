// § blockParamWrittenRhs405
module top();
initial begin
  localparam int K = 3 + 4;
  $display("%d", K);
end
endmodule
