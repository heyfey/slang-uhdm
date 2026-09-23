// face-2 break: imported package parameter = '{a: 4'h7, b: 4'h3}, read in a case item (unqualified) and in an if
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } pair_t;
  parameter pair_t P = '{a: 4'h7, b: 4'h3};
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
