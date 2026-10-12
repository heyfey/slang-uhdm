// § hcTrailIdxNamesByPortChain296
module sub (input logic [1:0] a, output logic y);
  assign y = a[0];
endmodule
module dut(output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; int i;
  sub u (.a({q.f[i], q.f[i+1]}), .y(y));
endmodule
