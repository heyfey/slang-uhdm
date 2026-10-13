// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module tgt (input logic a, input logic b, output logic o);
  assign o = a;
endmodule
module chk (input logic a, input logic b);
  ifc u (.clk(a & b));
endmodule
module top (input logic a, input logic b, output logic o);
  tgt t (.a(a), .b(b), .o(o));
endmodule
bind tgt chk c (.a(a), .b(b));
