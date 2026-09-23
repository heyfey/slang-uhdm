// face-2 unqualified measure: P = 8'({2{4'h3}})
package pk;
  
  parameter logic [7:0] P = 8'({2{4'h3}});
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
