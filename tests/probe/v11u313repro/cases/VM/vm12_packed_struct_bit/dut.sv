// § ifaceHcSelNamedByInst313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
typedef struct packed { logic a; logic b; } st_t;
module top (input st_t st, output logic o);
  ifc u (.clk(st[1]));
  child c0 (.p(u), .o(o));
endmodule
