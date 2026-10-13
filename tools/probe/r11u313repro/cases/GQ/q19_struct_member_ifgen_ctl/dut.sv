// § ifaceHcSelNamedByInst313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
typedef struct packed { logic a; logic b; } s_t;
module top (input s_t ck, output logic o);
  if (1) begin : g
    ifc u (.clk(ck.b));
    child c0 (.p(u), .o(o));
  end
endmodule
