// § opCtxBindableTarget201v § opCtxTargetAncestorBind208v
module child (input logic [3:0] a, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  assign imp = f(a) & 4'd3;
  assign o = a;
endmodule
module top (input logic [3:0] a, output logic [3:0] o);
  wire imp;
  child c (.a(a), .o(o));
endmodule
