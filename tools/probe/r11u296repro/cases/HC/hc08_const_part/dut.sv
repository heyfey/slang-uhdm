// § hcTrailIdxNamesByPortChain296
module subv (input logic [1:0] a, output logic y);
  assign y = a[0];
endmodule
module dut(output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  st_t qa [4];
  logic [3:0] k;
  int i;
  logic [31:0] v;
  localparam int P = 2;
  subv u (.a(q.f[P+1:P]), .y(y));
endmodule
