// § blockParamWrittenRhs405
module top();
initial begin
  parameter signed S = -2;
  parameter U = 5;
  $display("%d %d", S, U);
end
endmodule
