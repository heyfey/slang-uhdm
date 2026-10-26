// § errTypePortSyntaxRange440
module m #(parameter x = "inv") (input clk);
  function automatic void f(); logic [x-1:0] q; endfunction
  if (1) begin : g logic [x-1:0] gv; end
endmodule
module top; endmodule
