// § tfFoldCaseInsideBoundModule282
package pk; parameter int PA = 1; parameter int PB = 3; endpackage
module top import pk::*; (input logic [3:0] a, output logic z);
  function automatic logic f(input logic [3:0] x);
    if (x inside {[PA:PB], 4'd9}) return 1'b1;
    return 1'b0;
  endfunction
  assign z = f(a);
endmodule
