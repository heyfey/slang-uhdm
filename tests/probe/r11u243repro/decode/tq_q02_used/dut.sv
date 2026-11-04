// § cloneLoopVarClassPropArrayTs238 (decode of pass 238 residue d03, the package queue / dynamic typedef listing; ParamEmit, sister ground)
// package typedefs of a queue and a dynamic array used by module variables
package p;
  typedef int iq_t[$];
  typedef logic [3:0] id_t[];
endpackage
module top;
  import p::*;
  iq_t q;
  id_t d;
  initial begin q.push_back(1); d = new[2]; end
endmodule
