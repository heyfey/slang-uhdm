// § queueMemberSpanToDim212 — the queue member written inside a macro body
`define QMEM(t, n) t n[$];
package p;
  typedef struct {
    int k;
    `QMEM(string, args)
  } a_t;
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
