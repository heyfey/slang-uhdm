// § tfFoldCaseInsideBoundModule282
package pk; parameter int P = 4; endpackage
module top  #(parameter int P = 4) (input logic [7:0] a, output logic [7:0] z);
  task automatic t(input logic [7:0] x, output logic [7:0] y);
    case (x) P: y = 1; default: y = 0; endcase
    if (x inside {[P:7]}) y = 2;
  endtask
  always_comb t(a, z);
endmodule
