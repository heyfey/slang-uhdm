// face-2 qualified break: pk::P = OP_SYS, read in a case item
package pk;
  typedef enum logic [7:0] { OP_SYS = 8'h73, OP_LUI = 8'h37 } op_e;
  parameter op_e P = OP_SYS;
endpackage
module top (input logic [7:0] x, output logic [3:0] y);
  always_comb begin
    y = 4'd0;
    case (x)
      pk::P: y = 4'd1;
      8'hFF: y = 4'd2;
      default: y = 4'd7;
    endcase
  end
endmodule
