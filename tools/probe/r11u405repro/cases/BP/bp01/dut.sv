// § blockParamWrittenRhs405
module top();
initial begin
  parameter [3:0] val0 = 4'b000x;
  $display("%d", $isunknown(val0));
end
endmodule
