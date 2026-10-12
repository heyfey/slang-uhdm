// § dynAssocMemberSpanToDim295
module dut (output int o);
  typedef struct { int f[3]; int q[$]; int k; } sf_t;
  sf_t v;
  assign o = 0;
endmodule
