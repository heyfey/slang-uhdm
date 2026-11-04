// § hcTrailIdxNamesByPortChain296
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut(output logic [1:0] y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  st_t qa [4];
  logic [3:0] k;
  int i;
  logic [31:0] v;
  sub u0 (.a(q.f[i]), .y(y[0]));
  sub u1 (.a(q.f[k[2]]), .y(y[1]));
endmodule
