// § foreachThisArrAtThisToken207: foreach over this.<array> for associative, queue, dynamic and fixed arrays, short and long names (BuildUVMPkg m_predecessors)
package p;
class C;
  bit m_predecessors[C];
  int q[$];
  int d[];
  int f[4];
  function void walk(C other);
    foreach (this.m_predecessors[pred]) pred.q.push_back(1);
    foreach (this.q[i]) q[i] = i;
    foreach (this.d[j]) d[j] = j;
    foreach (this.f[k]) f[k] = k;
    foreach (other.m_predecessors[o]) o.q.push_back(2);
    foreach (m_predecessors[m]) m.q.push_back(3);
  endfunction
endclass
endpackage
module top; endmodule
