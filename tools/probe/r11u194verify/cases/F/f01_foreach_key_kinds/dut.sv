// § foreachAssocLoopVarIdxTs183 § foreachAssocLocalSharesDeclTs183: foreach loops over associative locals keyed by string, int, a typedef and an enum in a package function
package p;
  typedef enum {E0, E1} e_t;
  typedef logic [5:0] k_t;
  function automatic int f();
    int ms[string];
    int mi[int];
    int mk[k_t];
    int me[e_t];
    int n;
    foreach (ms[i]) n += ms[i];
    foreach (mi[j]) n += mi[j];
    foreach (mk[k]) n += mk[k];
    foreach (me[l]) n += me[l];
    return n;
  endfunction
endpackage
module top; endmodule
