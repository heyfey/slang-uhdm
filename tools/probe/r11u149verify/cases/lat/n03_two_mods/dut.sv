// § impLhsCloneArrayTsOwnCopy140
package pk;
  parameter logic [3:0] A[2] = '{4'h1, 4'h2};
endpackage
module m1 import pk::*; #(parameter int W = 1) (input logic s, output logic [3:0] o);
  assign o = A[s];
endmodule
module dut(input logic s, output logic [3:0] o1);
  m1 #(.W(2)) u1(.s(s), .o(o1));
endmodule
