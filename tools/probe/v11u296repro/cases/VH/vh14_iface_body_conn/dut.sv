// § hcTrailIdxNamesByPortChain296
interface ifc;
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; int i;
  logic o;
endinterface
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut(output logic y);
  ifc bus();
  sub u (.a(bus.q.f[bus.i]), .y(y));
endmodule
