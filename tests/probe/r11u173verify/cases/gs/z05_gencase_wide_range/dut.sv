// § genProcFoldDeclTsScopeNamed167 — a parameter with a `[W*2-1:0]` range folded in a gen-case process
module top #(parameter int W = 3, parameter logic [W*2-1:0] Z = '1) (input logic clk, output logic [W*2-1:0] q);
  case (W)
    3: begin : c3
      always_ff @(posedge clk) q <= Z;
    end
    default: begin : cd
      always_ff @(posedge clk) q <= '0;
    end
  endcase
endmodule
