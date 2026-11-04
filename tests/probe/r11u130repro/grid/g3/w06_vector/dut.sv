// § wildcardConnRefSpan130
module sub(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 4'd1;
endmodule
module top(input logic [3:0] a, output logic [3:0] y);
  sub u1(  .*  );
endmodule
