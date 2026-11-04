// § opCtxBindableTarget201v § opCtxTargetAncestorBind208v
module unused (input logic [3:0] a);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  assign imp = f(a) & 4'd3;
endmodule
module top (input logic [3:0] a);
endmodule
