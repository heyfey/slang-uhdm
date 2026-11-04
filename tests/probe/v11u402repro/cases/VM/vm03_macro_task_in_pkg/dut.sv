// § oobMacroDefAtExpansion402
`define DEF_T(N) task c::N(); endtask
package p;
class c;
  extern task t1();
  extern task t2();
endclass
`DEF_T(t2)
task c::t1(); endtask
endpackage
module top;
endmodule
