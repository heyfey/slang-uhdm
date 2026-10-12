// § hcTrailIdxNamesByPortChain296
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut(output logic y);
  typedef struct packed {logic [3:0][7:0] g;} s2_t;
  s2_t z;
  int i, j;
  sub u (.a(z.g[i][j]), .y(y));
endmodule
