// § queueMemberSpanToDim212 — two queue declarators in one member declaration, and a member with whitespace before the dimension
package p;
  typedef struct {
    int q1[$], q2 [$];
  } a_t;
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
