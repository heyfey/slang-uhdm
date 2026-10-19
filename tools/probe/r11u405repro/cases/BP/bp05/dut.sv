// § blockParamWrittenRhs405
module top();
initial begin
  parameter int Y = 3;
  $display("%d", Y);
end
endmodule
