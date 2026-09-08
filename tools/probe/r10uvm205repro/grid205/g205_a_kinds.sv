// r10uvm205 arm A — THE KIND TABLE.  Every typespec kind LAW S covers, plus
// the three it does not (packed-array / enum / struct typedefs) and a class
// typedef, each bound as the ELEMENT of an array declared inside a
// WILDCARD-IMPORT CLONE body.  One golden, both views.
package p205a_k;
  typedef bit   [7:0]     bt205;
  typedef logic [15:0]    lt205;
  typedef int             it205;
  typedef byte            yt205;
  typedef integer         gt205;
  typedef shortint        ht205;
  typedef longint         nt205;
  typedef bit [3:0][7:0]  pt205;
  typedef enum bit [1:0] { E0205, E1205 } et205;
  typedef struct packed { bit a205; bit b205; } st205;

  class C205;
    bt205 prop_a205[];              // a class PROPERTY, never a body local
    extern function int m205(input bt205 fio205[]);
  endclass

  function int C205::m205(input bt205 fio205[]);
    bt205 mb205[];
    lt205 ml205[];
    return fio205.size() + mb205.size() + ml205.size() + prop_a205.size();
  endfunction

  function automatic int fa205(input bt205 fio205[]);
    bt205 la205[];
    lt205 lb205[];
    it205 lc205[];
    yt205 ld205[];
    gt205 le205[];
    ht205 lh205[];
    nt205 ln205[];
    pt205 lp205[];
    et205 lg205[];
    st205 ls205[];
    bt205 lq205[$];
    bt205 lf205[4];
    return fio205.size() + la205.size() + lb205.size() + lc205.size()
         + ld205.size() + le205.size() + lh205.size() + ln205.size()
         + lp205.size() + lg205.size() + ls205.size() + lq205.size()
         + int'(lf205[0]);
  endfunction
endpackage

package p205b_k;
  import p205a_k::*;
  function automatic int gb205();
    bt205 ca205[];
    C205 c205;
    c205 = new();
    return fa205(ca205) + c205.m205(ca205);
  endfunction
endpackage

module g205_a_kinds;
  import p205b_k::*;
  int r205;
  initial r205 = gb205();
endmodule
