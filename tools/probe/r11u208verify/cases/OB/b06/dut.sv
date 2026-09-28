// § opCtxBindableTarget201v § opCtxTargetAncestorBind208v
interface ifc (input logic [3:0] a);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  logic [3:0] z;
  assign z = f(a) + 4'd1;
endinterface
module m1 (input logic [3:0] a);
  ifc i (.a(a));
endmodule
module m2 (input logic [3:0] a);
  logic [3:0] z;
  ifc i (.a(a));
endmodule
module top (input logic [3:0] a);
  m1 u1 (.a(a));
  m2 u2 (.a(a));
endmodule
