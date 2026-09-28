// § opCtxBindableTarget201v § opCtxRefArgBare201
`default_nettype wire
interface ifc (input logic [3:0] a, output logic [3:0] y);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  logic [3:0] z;
  assign y = f(a) + 4'd1;
  assign z = f(a) - 4'd2;
  modport M(input a, output y);
endinterface
module child (input logic [3:0] a, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  assign imp = f(a) & 4'd3;
  assign o = imp;
endmodule
module o06 (input logic [3:0] a, output logic [3:0] y, output logic [3:0] o);
  ifc i (.a(a), .y(y));
  child c (.a(a), .o(o));
endmodule
