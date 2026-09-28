// § queueMemberSpanToDim212 — r11u217 q02: a queue member whose element is a packed vector with a range (`logic [7:0] q[$]`), a queue of a class handle, and a queue of strings, in a PACKAGE struct typedef used by a class
package p;
  class k; int v; endclass
  typedef struct {
    logic [7:0] q[$];
    k h[$];
    string s[$];
  } a_t;
  class c;
    a_t m;
  endclass
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
