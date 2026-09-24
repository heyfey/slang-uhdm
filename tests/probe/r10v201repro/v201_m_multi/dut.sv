// v201 arm M — the same import copy at 1, 2 and 3 INSTANCES.
package p201vm;
  parameter M_A = 13;
  parameter M_B = M_A;
endpackage
module leaf201vm;
  import p201vm::*;
endmodule
module m201vm;
  leaf201vm u1();
  leaf201vm u2();
  leaf201vm u3();
endmodule
