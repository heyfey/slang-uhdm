// § impLhsCloneArrayTsOwnCopy140
package pk;
  parameter logic signed [7:0] T[2] = '{8'sd3, -8'sd4};
endpackage
module dut import pk::*; #(parameter int W = 1) (input logic sel, output logic signed [7:0] o);
  assign o = T[sel];
endmodule
