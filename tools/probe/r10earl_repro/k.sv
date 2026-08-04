package pa;
  parameter int W = 16;
endpackage

package pb;
  parameter logic [pa::W-1:0] Q = 'h0;
  parameter int               R = 4;
  parameter logic [R-1:0]     S = 'h0;
endpackage

module m4 #(
  parameter int Z = 1
) (
  input clk_i
);
endmodule
