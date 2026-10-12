// § dynAssocMemberSpanToDim295
typedef struct {int m[]; byte b[int];} us_t;
module dut (output int o);
  us_t u;
  assign o = 0;
endmodule
