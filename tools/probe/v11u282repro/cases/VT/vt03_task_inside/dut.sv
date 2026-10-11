// § tfFoldCaseInsideBoundModule282
package pk; parameter int PA = 1; parameter int PB = 3; endpackage
module top import pk::*; (input logic [3:0] a, output logic z);
  task automatic t(input logic [3:0] x, output logic y);
    y = x inside {[PA:PB]};
  endtask
  always_comb t(a, z);
endmodule
