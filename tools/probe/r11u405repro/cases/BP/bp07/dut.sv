// § blockParamWrittenRhs405
module top();
initial begin
  localparam [7:0] W = 8'hA5;
  $display("%d", W);
end
endmodule
