// § hcTrailIdxNamesByPortChain296
interface ifc;
  typedef struct packed {logic [31:0] f;} st_t;
  st_t s;
endinterface
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut(output logic y);
  ifc bus ();
  int i;
  sub u (.a(bus.s.f[i]), .y(y));
endmodule
