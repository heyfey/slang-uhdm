// § tfFoldCaseInsideBoundModule282
package pk; parameter int PA = 1; parameter int PB = 3; endpackage
module top import pk::*; (input logic [3:0] a, output logic [1:0] z);
  function automatic logic [1:0] f(input logic [3:0] x);
    return (x inside {[PA:PB]}) ? 2'd1 : 2'd2;
  endfunction
  assign z = f(a);
endmodule
