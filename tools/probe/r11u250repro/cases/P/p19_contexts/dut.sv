// § pkgArrTdBindCopies250
package p;
  typedef int q_t[$];
  typedef logic [7:0] b_t[2];
endpackage
interface ifc;
  import p::*;
  q_t iq;
  b_t ib;
endinterface
module sub;
  import p::*;
  b_t sb;
  q_t sq;
endmodule
module top;
  import p::*;
  ifc u();
  sub s1();
  sub s2();
  if (1) begin : g
    b_t gb;
    q_t gq;
  end
  function automatic int f(q_t a);
    b_t loc;
    return a.size();
  endfunction
  q_t q;
  int n;
  initial n = f(q);
endmodule
