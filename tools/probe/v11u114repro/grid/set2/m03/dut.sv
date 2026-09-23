// face-2 unqualified measure: P = f({4'h1, 4'h2})
package pk;
  function automatic logic [7:0] f(input logic [7:0] a); return a+1; endfunction
  parameter logic [7:0] P = f({4'h1, 4'h2});
endpackage
module top import pk::*; (input logic [7:0] x, output logic [3:0] y);
  always_comb begin
    y = 4'd0;
    case (x)
      P: y = 4'd1;
      default: y = 4'd7;
    endcase
  end
endmodule
