// § dynAssocMemberSpanToDim295
class C;
  typedef struct {int m[string]; int n[];} cs_t;
  cs_t v;
endclass
module dut (output int o);
  C h;
  assign o = 0;
endmodule
