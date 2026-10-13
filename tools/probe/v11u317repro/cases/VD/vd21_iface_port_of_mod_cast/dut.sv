// § selIdxCastTsNamedBySel317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module mid (ifc b, input logic [2:0] s, output logic o);
  assign o = b.sig[2'(s)];
endmodule
module top (input logic c, input logic [2:0] s, output logic o);
  ifc u (.clk(c));
  mid m (.b(u), .s(s), .o(o));
endmodule
