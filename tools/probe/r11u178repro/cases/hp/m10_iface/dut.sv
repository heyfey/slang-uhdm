// § hierPathSelIdxAtPath178
typedef struct { int v; } s_t;
typedef struct { s_t w[4]; } m_t;
interface bus; m_t m; endinterface
module dut(bus b);
  int k, r1, r2;
  assign r1 = b.m.w[k].v;
  initial r2 = b.m.w[k].v;
endmodule
module top; bus b(); dut d(b); endmodule
