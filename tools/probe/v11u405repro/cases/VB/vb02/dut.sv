// § blockParamWrittenRhs405
module top();
initial begin : nb
  parameter logic [7:0] P = 8'hA5;
  $display("%h", P);
end
endmodule
