// § dynAssocMemberSpanToDim295
`define MEM(n) int n[string];
module dut (output int o);
  typedef struct { `MEM(mm) int k; } sm_t;
  sm_t v;
  assign o = 0;
endmodule
