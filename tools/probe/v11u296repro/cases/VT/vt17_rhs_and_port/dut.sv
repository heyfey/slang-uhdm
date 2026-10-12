// § castTsInPathIdxByChain296
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut(output logic o, output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; logic [7:0] k;
  assign o = q.f[3'(k) + 1];
  sub u (.a(q.f[3'(k)]), .y(y));
endmodule
