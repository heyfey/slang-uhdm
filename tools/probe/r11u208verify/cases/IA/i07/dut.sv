// § ifaceArrPortElemViewNamedByArray200
typedef struct packed { logic [3:0] f; logic g; } st_t;
interface sif(input bit clock);
  st_t s;
  modport M(input clock, input s);
endinterface
program tc(sif.M p[2]);
  initial $display(p[1].s.f, p[0].s.g);
endprogram
module top; bit clk; sif sa[2](clk); tc TC(.p(sa)); endmodule
