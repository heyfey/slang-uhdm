// § bitSelMethodCallIdxSpan207: lvalue selects indexed by method calls (blocking, compound, increment, nonblocking) next to rvalue selects in the same statement
package p;
class C;
  int m[int];
  int q[$];
  int fx[8];
  function int gi(int a = 0); return a; endfunction
  task t(C c);
    m[c.gi(1)] = m[c.gi(2)];
    m[c.gi(3)] += m[c.gi()];
    m[c.gi(4)]++;
    ++m[c.gi(5)];
    fx[c.gi(6)] <= q[c.gi(7)];
    q[c.gi(1)] = q.size() > c.gi() ? q[c.gi(0)] : 0;
  endtask
endclass
endpackage
module top; endmodule
