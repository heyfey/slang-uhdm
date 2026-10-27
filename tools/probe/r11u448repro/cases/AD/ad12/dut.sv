// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  function automatic logic f(input logic a); return a; endfunction
  logic r; always @(posedge clk) r = f(undecl_x);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
