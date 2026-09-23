// face-2 break: imported package parameter = ~8'h0F, read in a case item (unqualified) and in an if
package pk;
  
  parameter logic [7:0] P = ~8'h0F;
endpackage
module top import pk::*; (input logic [7:0] x, output logic [3:0] y);
  always_comb begin
    y = 4'd0;
    case (x)
      P: y = 4'd1;
      8'hFF: y = 4'd2;
      default: y = 4'd7;
    endcase
  end
endmodule
