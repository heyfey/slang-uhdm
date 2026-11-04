// § concatRangeSelIsConcat401
module top();
  bit [3:0] a;
  bit [7:0] b = 8'b10101100;
  bit [7:0] c = 8'b01010011;
  initial a = {b, c}[9:6];
endmodule
