// § impLhsCloneArrayTsOwnCopy140
package pk;
  parameter byte B[3] = '{8'd1, 8'd2, 8'd3};
endpackage
module dut import pk::*; #(parameter int W = 1) (input logic [1:0] sel, output byte o);
  function automatic byte pick(input logic [1:0] s);
    return B[s];
  endfunction
  assign o = pick(sel);
endmodule
