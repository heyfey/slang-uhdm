// § hcPathIdxBindsDefNet311
interface pif (input logic c);
  logic s;
endinterface
module dut (output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  int i;
  pif pi (.c(q.f[i]));
  assign y = pi.s;
endmodule
