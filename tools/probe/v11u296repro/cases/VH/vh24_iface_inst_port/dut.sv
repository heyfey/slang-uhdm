// § hcTrailIdxNamesByPortChain296
interface ifc (input logic a);
  logic y;
  assign y = a;
endinterface
module dut(output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; int i;
  ifc bus (.a(q.f[i]));
  assign y = bus.y;
endmodule
