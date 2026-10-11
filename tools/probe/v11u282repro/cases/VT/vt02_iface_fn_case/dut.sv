// § tfFoldCaseInsideBoundModule282
package pk; parameter logic [1:0] P_LIT = 2'd1; endpackage
interface ifc import pk::*; ();
  logic [1:0] a;
  function automatic logic f(input logic [1:0] x);
    case (x) P_LIT: return 1'b1; default: return 1'b0; endcase
  endfunction
endinterface
module top(input logic [1:0] a, output logic z); ifc i(); assign i.a = a; assign z = i.f(a); endmodule
