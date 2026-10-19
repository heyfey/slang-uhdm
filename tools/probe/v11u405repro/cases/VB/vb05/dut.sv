// § blockParamWrittenRhs405
module top();
  localparam M = 4;
initial begin
  localparam [M-1:0] Q = M'(3);
  $display("%d", Q);
end
endmodule
