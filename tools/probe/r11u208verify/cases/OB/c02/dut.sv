// § opCtxBindableTarget201v § opCtxTargetAncestorBind208v
interface ifc (input logic [3:0] a);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  wire [3:0] w;
  logic [3:0] v;
  assign w = f(a) + 4'd1;
  assign v = f(a) + 4'd2;
endinterface
module top (input logic [3:0] a);
  ifc i (.a(a));
endmodule
