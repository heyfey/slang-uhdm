// r10v189 arm K — INDEX KINDS again, but re-ordered, re-cased and with TYPEDEF
// CHAINS, a STRUCT index, a packed-vector typedef index and a class typedef'd
// twice, so agreement cannot come from the arm echoing arm A's shape.
package ZKEEL189V;
  typedef struct packed { bit [3:0] sfA189V; bit [3:0] sfB189V; } stK189V;
  typedef bit [7:0] vecK189V;
  class KEEL189V;
    int kA189V;
  endclass
  typedef KEEL189V td1K189V;
  typedef td1K189V td2K189V;             // typedef CHAIN of a class handle
  typedef enum bit [1:0] { ZK189V, YK189V, XK189V } enK189V;
  typedef int unsigned uintK189V;

  class RIB189V;
    extern function int ribK189V();
  endclass

  function int RIB189V::ribK189V();
    bit wildK189V[*];
    bit td2K189Va[td2K189V];
    bit vecK189Va[vecK189V];
    bit stK189Va[stK189V];
    bit uintK189Va[uintK189V];
    bit enK189Va[enK189V];
    bit intK189Va[int];
    bit strK189Va[string];
    bit clsK189Va[KEEL189V];
    wildK189V[11] = 1'b1;
    td2K189Va[null] = 1'b1;
    vecK189Va[8'h5a] = 1'b1;
    stK189Va[8'h11] = 1'b1;
    uintK189Va[7] = 1'b1;
    enK189Va[YK189V] = 1'b1;
    intK189Va[-3] = 1'b1;
    strK189Va["Q"] = 1'b1;
    clsK189Va[null] = 1'b1;
    return 0;
  endfunction

  function int freeRibK189V();
    bit fEnK189V[enK189V];
    bit fVecK189V[vecK189V];
    bit fClsK189V[td1K189V];
    fEnK189V[XK189V] = 1'b1;
    fVecK189V[8'h01] = 1'b1;
    fClsK189V[null] = 1'b1;
    return 1;
  endfunction
endpackage

package ZSPAR189V;
  import ZKEEL189V::*;
  function int useK189V();
    RIB189V rK189V;
    int tK189V;
    rK189V = new();
    tK189V = rK189V.ribK189V();
    tK189V = tK189V + freeRibK189V();
    return tK189V;
  endfunction
endpackage

module topZKEEL189V;
  import ZSPAR189V::*;
  int rzK189V;
  initial rzK189V = useK189V();
endmodule
