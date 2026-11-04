// § hcTrailIdxNamesByPortChain296
program pg (input logic a);
  initial $display("%b", a);
endprogram
module dut;
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; int i;
  pg p (.a(q.f[i]));
endmodule
