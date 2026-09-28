// § queueMemberSpanToDim212 — verifier: a queue member whose name comes from a macro argument
`define MEM(n) int n[$];
package p;
  typedef struct {
    `MEM(qq)
    int z;
  } a_t;
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
