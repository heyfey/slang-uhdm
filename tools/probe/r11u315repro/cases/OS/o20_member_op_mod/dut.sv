// § ifaceHcOpSelByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
typedef struct packed { logic a; logic b; } st_t;
module top (input st_t ck, output logic o);
  ifc u (.clk(ck.a & ck.b));
  assign o = u.sig[0];
endmodule
