// § queueMemberSpanToDim212 — a queue member in a module-scope unpacked struct variable
module dut(input logic i, output logic o);
  typedef struct {
    int n;
    int q[$];
  } a_t;
  a_t v;
  assign o = i;
endmodule
