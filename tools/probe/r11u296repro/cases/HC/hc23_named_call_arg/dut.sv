// § hcTrailIdxNamesByPortChain296
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut(output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  int i;
  function automatic int fz(input int x, input int z = 0); return x + z; endfunction
  sub u (.a(q.f[fz(.x(i))]), .y(y));
endmodule
