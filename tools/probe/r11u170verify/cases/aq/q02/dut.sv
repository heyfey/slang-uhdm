// § arrQueryFoldAtBound158
package pk; parameter logic [9:4] P = '0; endpackage
module top (output logic [7:0] o);
  typedef logic [5:3] t_t;
  localparam t_t Q = '0;
  localparam int A = $right(pk::P);
  localparam int B = $low(Q);
  assign o = A + B;
endmodule
