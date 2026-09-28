// § queueMemberSpanToDim212 — verifier: a queue member in an interface-scope struct typedef
interface ii;
  typedef struct { int q[$]; int n; } t_t;
  t_t t;
endinterface
module dut(input logic i, output logic o);
  ii u();
  assign o = i;
endmodule
