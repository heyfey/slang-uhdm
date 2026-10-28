// § taskValBareRefGenNone451v
module m #(parameter P) (input clk);
  task t; endtask
  case (P)
    1: begin : c1 initial $display("%b", t); end
    default: begin : cd end
  endcase
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
