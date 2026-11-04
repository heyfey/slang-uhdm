// § queueMemberSpanToDim212 — verifier: a queue member whose dimension comes from a macro
`define QD [$]
package p;
  typedef struct {
    int q `QD;
  } a_t;
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
