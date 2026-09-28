// § opCtxBindableTarget201v § opCtxTargetAncestorBind208v
interface ifc (input logic [3:0] a);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  logic [3:0] z;
  wire [3:0] u;
  assign z = f(a) + 4'd1;
  assign u = f(a) + 4'd2;
endinterface
module top (input logic [3:0] a, output logic [3:0] z);
  wire [3:0] u;
  ifc i (.a(a));
  assign z = i.z;
  assign u = i.u;
endmodule
