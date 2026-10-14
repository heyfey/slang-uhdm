// § ifaceHcVarSelWholeByInst319
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic [1:0] k [2], input logic a, output logic o);
  typedef struct packed { logic [1:0] f; } st_t;
  st_t st;
  assign st = s;
  ifc u (.clk(m[st.f][t]));
  assign o = u.sig[0];
endmodule
