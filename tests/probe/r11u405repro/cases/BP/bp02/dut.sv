// § blockParamWrittenRhs405
module top();
initial begin
  parameter [3:0] val3 = 4'b0000;
  $display("%d", $isunknown(val3));
end
endmodule
