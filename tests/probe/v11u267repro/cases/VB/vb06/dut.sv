// § genCaReplParentBoundLhs267
module m #(parameter int W = 4) (input logic [3:0] i, output wire [3:0] o);
  wire [3:0] t;
  case (W)
    4: begin : c4
      assign t = {W{1'b1}};
    end
    default: begin : cd
      assign t = '0;
    end
  endcase
  assign o = t & i;
endmodule
module top(input logic [3:0] i, output wire [3:0] o);
  m u(.i(i), .o(o));
endmodule
