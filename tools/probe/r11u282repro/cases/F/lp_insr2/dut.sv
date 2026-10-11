// § tfFoldCaseInsideBoundModule282
package pk; parameter int P = 4; endpackage
module top   (input logic [7:0] a, output logic [7:0] z);
  localparam int P = 4;
  function automatic logic [7:0] f(input logic [7:0] x);
    return x inside {[P-1:P+1]};
  endfunction
  assign z = f(a);
endmodule
