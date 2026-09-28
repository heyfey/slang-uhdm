// § opCtxBindableTarget201v § opCtxTargetAncestorBind208v

interface ifc (input logic [3:0] a, output logic [3:0] y);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  assign y = f(a) + 4'd1;
endinterface
module top (input logic [3:0] a, output logic [3:0] y);
  ifc i (.a(a), .y(y));
endmodule
