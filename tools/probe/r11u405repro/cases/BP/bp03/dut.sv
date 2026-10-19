// § blockParamWrittenRhs405
module top();
initial begin
  parameter [3:0] val3 = 4'b0010;
  parameter val4 = 'x;
  $display("%d %d", val3, val4);
end
endmodule
