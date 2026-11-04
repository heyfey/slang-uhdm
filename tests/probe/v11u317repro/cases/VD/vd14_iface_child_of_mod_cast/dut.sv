// § selIdxCastTsNamedBySel317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module mid (input logic [3:0] ck, input logic [2:0] s, output logic o);
  ifc u (.clk(ck[2'(s)]));
  assign o = u.sig[0];
endmodule
module top (input logic [3:0] ck, input logic [2:0] s, output logic o);
  mid m (.ck(ck), .s(s), .o(o));
endmodule
