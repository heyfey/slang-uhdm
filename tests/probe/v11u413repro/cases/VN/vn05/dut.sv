// § unitTdCloneNoPrefixBit413
typedef bit [7:0] i_t;
module top (output [7:0] o);
  localparam i_t L = 8'h3c;
  assign o = L;
endmodule
