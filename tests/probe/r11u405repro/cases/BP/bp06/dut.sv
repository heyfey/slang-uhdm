// § blockParamWrittenRhs405
module top();
initial begin
  parameter [3:0] V = 2 + 1;
  $display("%d", V);
end
endmodule
