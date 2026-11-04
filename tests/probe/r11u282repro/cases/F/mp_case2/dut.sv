// § tfFoldCaseInsideBoundModule282
package pk; parameter int P = 4; endpackage
module top  #(parameter int P = 4) (input logic [7:0] a, output logic [7:0] z);
  
  function automatic logic [7:0] f(input logic [7:0] x);
    case (x) P-1, 2: return 1; default: return 0; endcase
  endfunction
  assign z = f(a);
endmodule
