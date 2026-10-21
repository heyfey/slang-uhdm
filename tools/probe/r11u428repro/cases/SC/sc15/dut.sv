// § caWholeSysCallSharesDefCell428
module m #(parameter [3:0] P = 4'b1011) (output [2:0] y);
  assign y = $countones(P);
  wire [2:0] w = $countones(P);
endmodule
module top(output [2:0] b);
  m #(.P(4'b0111)) u(b);
endmodule
