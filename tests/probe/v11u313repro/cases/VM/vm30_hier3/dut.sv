// § ifaceHcSelNamedByInst313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module sub2 (output logic x);
  assign x = 1'b1;
endmodule
module sub (output logic y);
  sub2 t (.x(y));
endmodule
module top (output logic o);
  sub s (.y());
  ifc u (.clk(s.t.x));
  child c0 (.p(u), .o(o));
endmodule
