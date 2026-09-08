// r10v205 arm L — THE SHARING MAXIMISER.  Every construct that made our emitter
// hand two declarations ONE element ref in the corpus (R1: a queue declaration
// plus its `foreach` reference variable) applied to a CLONE body and to the
// HOME body of the SAME type at once, plus a `ref` formal, a `const ref`
// formal, and the same array type declared twice inside one body.  If the
// element ref is shared across a clone/home pair the law's guard must refuse it.
package p205a_l;
  typedef bit [7:0] bt205;
  function automatic int fhome205(input bt205 hio205[$]);
    bt205 haddrs205[$];
    int s205 = 0;
    haddrs205.push_back(8'h1);
    foreach (haddrs205[i205]) s205 += int'(haddrs205[i205]);
    foreach (hio205[j205])    s205 += int'(hio205[j205]);
    return s205;
  endfunction
  function automatic int fref205(ref bt205 rio205[$], const ref bt205 cio205[$]);
    bt205 raddrs205[$];
    int s205 = 0;
    foreach (raddrs205[i205]) s205 += int'(raddrs205[i205]);
    foreach (cio205[k205])    s205 += int'(cio205[k205]);
    rio205.push_back(8'h2);
    return s205;
  endfunction
endpackage

package p205b_l;
  import p205a_l::*;
  function automatic int gl205();
    bt205 cq205[$];
    bt205 dq205[$];
    int s205 = 0;
    foreach (cq205[i205]) s205 += int'(cq205[i205]);
    s205 += fhome205(cq205);
    s205 += fref205(cq205, dq205);
    return s205;
  endfunction
endpackage

module v205_l_reuse;
  import p205b_l::*;
  int r205;
  initial r205 = gl205();
endmodule
