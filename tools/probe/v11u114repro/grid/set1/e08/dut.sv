// case item in a module function returning, called from an assign; the param in the case EXPRESSION too
package pk; parameter logic [7:0] P = {4'h7, 4'h3}; endpackage
module top import pk::*; (input logic [7:0] x, output logic [3:0] y);
  function automatic logic [3:0] f(input logic [7:0] v);
    case (P) v: return 4'd1; default: return 4'd0; endcase
  endfunction
  assign y = f(x);
endmodule
