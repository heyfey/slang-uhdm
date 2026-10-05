// § unitTdLawS245
typedef logic [4:0] fiv_t;
module top(input logic [2:0] i, output logic [2:0] o, output logic [4:0] q);
  fiv_t w;
  a u(.i(i), .o(o));
  assign w = {i, 2'b0};
  assign q = w;
endmodule
