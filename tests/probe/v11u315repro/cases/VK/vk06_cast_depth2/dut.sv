// § ifaceConnCastTsNamedByPort315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module mid (input logic [1:0] a, output logic o);
  ifc u (.clk(1'(a) & a[1]));
  assign o = u.sig[0];
endmodule
module top (input logic [1:0] a, output logic o);
  mid m (.a(a), .o(o));
endmodule
