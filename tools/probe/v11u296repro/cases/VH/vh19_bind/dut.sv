// § hcTrailIdxNamesByPortChain296
module chk (input logic a);
endmodule
module sub (input logic a, output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; int i;
  assign y = a;
endmodule
module dut(output logic y);
  sub u (.a(1'b1), .y(y));
  bind sub chk c (.a(q.f[i]));
endmodule
