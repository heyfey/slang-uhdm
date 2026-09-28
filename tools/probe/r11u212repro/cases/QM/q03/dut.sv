// § queueMemberSpanToDim212 — a bounded queue member and a two-dimension member (queue of fixed arrays)
package p;
  typedef struct {
    int q[$:4];
    int r[2][$];
  } a_t;
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
