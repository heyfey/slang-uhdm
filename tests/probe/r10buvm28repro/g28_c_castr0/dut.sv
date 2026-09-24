// r10buvm28 R0 probe — THE NEW HEAD.  A CAST whose operand is a STREAMING
// CONCATENATION loses its cast `operation` (vpiOpType 67) and with it the
// `vpiTypespec` the judge reads first, for EVERY target type; a cast over any
// other operand keeps both.  Measured golden-vs-ours: lines 10-13 (cast over a
// stream) golden 7 operation nodes / ours 4; lines 14-19 (cast over a plain
// expression) 3 vs 3 and 6 vs 6.  This is uvm_pkg.sv:58249 and :58284.
package r0p;
  typedef enum { Z0, Z1, Z2 } ze;
  typedef enum bit [3:0] { W0, W1 } zw;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } zs;
  class C;
    ze  e1;  zw  e2;  zs  s1;  int i1;  bit [7:0] v1;
    function void f();
      bit __a[];
      e1 = ze'({ << bit { __a }});      // base-less enum cast over a stream
      e2 = zw'({ << bit { __a }});      // based-enum cast over a stream
      s1 = zs'({ << bit { __a }});      // packed-struct cast over a stream
      i1 = int'({ << bit { __a }});     // atom cast over a stream
      e1 = ze'(i1);                     // enum cast over a plain expr
      e2 = zw'(i1);
      s1 = zs'(i1);
      i1 = int'(v1);
      v1 = 8'(i1);
      i1 = int'({ v1, v1 });            // atom cast over a plain concat
    endfunction
  endclass
endpackage
