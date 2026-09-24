// case item reading an imported concat param inside a GENERATE block's always
package pk;
  typedef enum logic [6:0] { OP_SYS = 7'h73 } op_e;
  parameter logic [31:0] P_CAT = { 12'b0, 13'b0, {OP_SYS} };
endpackage
module top import pk::*; (input logic [31:0] x, output logic [3:0] y);
  if (1) begin : g
    always_comb begin
      y = 4'd0;
      case (x)
        P_CAT: y = 4'd1;
        default: y = 4'd7;
      endcase
    end
  end
endmodule
