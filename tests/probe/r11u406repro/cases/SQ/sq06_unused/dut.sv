// § sequenceDeclListed406
module top;
  logic a, b;
  sequence s4;
    a ##[1:3] b;
  endsequence
endmodule
