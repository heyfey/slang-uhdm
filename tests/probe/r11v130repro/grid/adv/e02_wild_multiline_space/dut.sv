// § wildcardConnRefSpan130
module sub(input logic [3:0] a, input logic b, output logic [3:0] y);
  assign y = a & {4{b}};
endmodule
module top(input logic [3:0] a, input logic b, output logic [3:0] y);
  sub u1 (  .*  ,
    .b(1'b1)
  );
endmodule
