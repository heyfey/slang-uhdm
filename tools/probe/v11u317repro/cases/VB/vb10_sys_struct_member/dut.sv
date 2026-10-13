// § genSysArgInnerUnbound317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
typedef struct packed { logic a; logic b; } st_t;
module top (input st_t v, input logic s, output logic o);
  if (1) begin : g
    ifc u (.clk($signed(v.a & s)));
  end
  assign o = g.u.sig[0];
endmodule
