// § tfFoldCaseInsideBoundModule282
package pk; parameter int P = 4; endpackage
module top import pk::*;  (input logic [7:0] a, output logic [7:0] z);
  
  function automatic logic [7:0] f(input logic [7:0] x);
    return (P > 2) ? x : 8'd0;
  endfunction
  assign z = f(a);
endmodule
