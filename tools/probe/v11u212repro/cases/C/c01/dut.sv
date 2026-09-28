// § queueMemberSpanToDim212 — verifier: a queue of fixed arrays member (queue first) and a packed-element queue member
package p;
  typedef struct {
    int q[$][2];
    logic [3:0] n[$];
  } a_t;
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
