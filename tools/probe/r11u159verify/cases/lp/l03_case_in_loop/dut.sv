// § genLpOperandTsNoParent152
module top(output int o);
   parameter int P [2] = '{7, 8};
   parameter int S = 1;
   for (genvar i = 0 ; i < 1 ; i++) begin : a
      case (S)
        1: begin : c
           localparam int L = P[0];
           assign o = L;
        end
        default: begin : d
           assign o = 0;
        end
      endcase
   end
endmodule
