// § queueMemberSpanToDim212 — a queue member in a class-scope struct typedef used by a class method local
package p;
  class c;
    typedef struct {
      string s;
      string q[$];
    } a_t;
    function void f();
      a_t t;
      t.s = "x";
    endfunction
  endclass
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
