// § macroConnInRange166 § ppOutputLine166
`define CONN(p, s, h, l) .p(s[h:l])
module sub(input logic [1:0] a, input logic [1:0] b, output logic [1:0] y);
  assign y = a & b;
endmodule
module top(input logic [7:0] a, input logic [7:0] b, output logic [1:0] y);
  sub u(`CONN(a, a, 3, 2),
        `CONN(b, b, 5,
              4),
        .y(y));
endmodule
