// § genProcFoldTsKeepsScope154
module rs #(parameter P = 4) (input clk, input [7:0] x, output [7:0] o);
  generate
    case (P)
      4: begin : c4
        reg [7:0] v;
        always @(posedge clk) v[P+1:P-2] <= x[P+1:P-2];
        assign o = v;
      end
      default: begin : cd
        assign o = x;
      end
    endcase
  endgenerate
endmodule
module top(input clk, input [7:0] x, output [7:0] o);
  rs r(clk, x, o);
endmodule
