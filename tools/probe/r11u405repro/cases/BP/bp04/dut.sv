// § blockParamWrittenRhs405
module top();
initial begin
  parameter X = 5;
  $display("%d", X);
end
endmodule
