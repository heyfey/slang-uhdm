`define UNUSED_M 1
module top(input logic [1:0] s, output logic [31:0] p, q);
  always_comb begin
    case (s)
      2'd0   : begin p = 0 ; q = 1     ; end
      default:                 begin p = 'x ; q = 'x     ; end
    endcase
  end
endmodule
