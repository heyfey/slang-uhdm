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
  for (genvar g = 0; g < 2; g++) begin : gb
    sub u (.a(q.f[k[g]]), .y(y[g]));
  end
endmodule
