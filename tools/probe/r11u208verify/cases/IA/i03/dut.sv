// § ifaceArrPortElemViewNamedByArray200
typedef struct packed { logic [3:0] f; logic g; } st_t;
interface sif;
  st_t s;
  logic [1:0] k;
  modport M(input s, output k);
endinterface
module sub(sif.M p[2], output logic [3:0] y);
  assign y = p[1].s.f;
  assign p[0].k = {p[0].s.g, p[1].s.g};
endmodule
module top(output logic [3:0] y);
  sif sa[2]();
  sub u(.p(sa), .y(y));
endmodule
