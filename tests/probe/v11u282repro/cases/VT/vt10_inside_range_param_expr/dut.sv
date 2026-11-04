// § tfFoldCaseInsideBoundModule282
package pk; parameter int PA = 1; endpackage
module top import pk::*; (input logic [3:0] a, output logic z);
  function automatic logic f(input logic [3:0] x);
    return x inside {[PA:4'd7], [4'd9:PA+9]};
  endfunction
  assign z = f(a);
endmodule
