// § ifaceHcVarSelWholeByInst319
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module mid (input logic [1:0][1:0] m, input logic [1:0] s, output logic o);
  ifc u (.clk(m[s][1]));
  assign o = u.sig[0];
endmodule
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic [1:0] k [2], input logic a, output logic o);
  logic o2;
  mid u1 (.m(m), .s(s), .o(o));
  mid u2 (.m(m), .s(t), .o(o2));
endmodule
