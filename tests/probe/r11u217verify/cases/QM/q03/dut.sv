// § queueMemberSpanToDim212 — r11u217 q03: a queue member followed on the same line by another declarator (`int a[$], b;`), a queue whose dimension is written with spaces and a comment (`int c [ $ ] /*q*/ ;`), in a class-scope struct
package p;
  class c;
    typedef struct {
      int a[$], b;
      int c [ $ ] /*q*/ ;
    } s_t;
    s_t m;
  endclass
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
