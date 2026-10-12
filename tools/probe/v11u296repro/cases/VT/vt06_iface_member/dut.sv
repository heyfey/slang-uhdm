// § castTsInPathIdxByChain296
interface ifc;
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
endinterface
module dut(output logic o);
  ifc bus();
  logic [7:0] k;
  assign o = bus.q.f[3'(k)];
endmodule
