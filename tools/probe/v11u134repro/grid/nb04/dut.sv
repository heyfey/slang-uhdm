// § elabNetTdCloneNoAlias134
module top(input logic [3:0] i, output logic [3:0] o);
  typedef reg [3:0] r_t;
  typedef logic [3:0] l_t;
  r_t x;
  l_t y;
  assign x = i;
  assign y = i;
  assign o = x ^ y;
endmodule
