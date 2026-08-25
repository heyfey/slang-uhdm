// r10uvm140 arm C — the alias and its BASE in DIFFERENT packages, reached
// three ways: wildcard import, explicit single import, and a fully-qualified
// `pkg::name` return type.  Also a base with THREE aliases so the map's
// pointer order cannot be what makes the arm agree.
package Quartz_base_pkg;
  typedef enum { Raw = 1, Cut = 2, Polished = 4 } stoneGrade;
  typedef struct packed { logic [3:0] karat; logic [3:0] clarity; } gemRec;
endpackage

package Onyx_alias_pkg;
  import Quartz_base_pkg::*;
  typedef stoneGrade StoneGrade_e;     // alias #1, in another package
  typedef stoneGrade grade_kind_t;     // alias #2
  typedef StoneGrade_e GradeChain_e;   // alias #3, of alias #1
  typedef gemRec     GemRec_s;
endpackage

package Topaz_use_pkg;
  import Quartz_base_pkg::*;
  import Onyx_alias_pkg::*;
  function StoneGrade_e wildAlias();   return Cut;      endfunction
  function grade_kind_t wildAlias2();  return Polished; endfunction
  function GradeChain_e wildChain();   return Raw;      endfunction
  function stoneGrade   wildBase();    return Raw;      endfunction
  function GemRec_s     wildGem();     GemRec_s r; return r; endfunction
endpackage

package Beryl_use_pkg;
  import Onyx_alias_pkg::grade_kind_t;
  import Quartz_base_pkg::stoneGrade;
  function grade_kind_t narrowAlias(); return stoneGrade'(2); endfunction
  function stoneGrade   narrowBase();  return stoneGrade'(1); endfunction
endpackage

module Lapidary;
  import Topaz_use_pkg::*;
  // fully-qualified return types, no import in sight
  function Onyx_alias_pkg::GradeChain_e qualifiedChain();
    return Quartz_base_pkg::Cut;
  endfunction
  function Quartz_base_pkg::stoneGrade qualifiedBase();
    return Quartz_base_pkg::Raw;
  endfunction
  function Onyx_alias_pkg::GemRec_s qualifiedGem();
    Onyx_alias_pkg::GemRec_s r; return r;
  endfunction

  Onyx_alias_pkg::GradeChain_e g;
  initial g = qualifiedChain();
endmodule
