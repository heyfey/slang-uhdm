// § blockParamWrittenRhs405
module top();
string s;
initial begin
  localparam string S = "ab";
  s = S;
end
endmodule
