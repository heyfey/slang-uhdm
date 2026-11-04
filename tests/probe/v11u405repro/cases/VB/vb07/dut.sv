// § blockParamWrittenRhs405
module top();
real r;
initial begin
  localparam real R = 1.5;
  r = R * 2.0;
end
endmodule
