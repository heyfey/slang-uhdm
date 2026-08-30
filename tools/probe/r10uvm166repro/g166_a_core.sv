// r10uvm166 GRID A -- THE CORE QUESTION.  MEASUREMENT ONLY.
// A declaration whose written type is a BARE NAME denoting a typedef of an
// UNPACKED ARRAY, with NO dimensions written on the declarator.  Element type
// varies: a class TYPE PARAMETER (the corpus shape, uvm_utils::types_t) vs a
// concrete type.  Homes vary: class static method body, nested begin, package
// free function, module initial.
package pk166a;

  class Cage166 #(type T166 = int);
    typedef T166 parQ166_t[$];
    typedef T166 parD166_t[];
    typedef T166 parA166_t[string];
    typedef T166 parF166_t[4];
    typedef int  conQ166_t[$];
    typedef int  conD166_t[];
    typedef int  conA166_t[string];
    typedef int  conF166_t[4];
    typedef T166 parS166_t;

    static function void dig166();
      parQ166_t pqVal166;
      parD166_t pdVal166;
      parA166_t paVal166;
      parF166_t pfVal166;
      conQ166_t cqVal166;
      conD166_t cdVal166;
      conA166_t caVal166;
      conF166_t cfVal166;
      parS166_t psVal166;
      int wrtQ166[$];
      T166 rawQ166[$];
      begin
        parQ166_t nqVal166;
        conQ166_t ncVal166;
      end
    endfunction
  endclass

  class Plain166;
    typedef int pcQ166_t[$];
    typedef int pcF166_t[2];
    static function void hoe166();
      pcQ166_t pcqVal166;
      pcF166_t pcfVal166;
    endfunction
  endclass

  typedef int pkgQ166_t[$];
  typedef int pkgF166_t[3];
  function void mow166();
    pkgQ166_t pgqVal166;
    pkgF166_t pgfVal166;
  endfunction

endpackage

module top166;
  import pk166a::*;
  typedef int modQ166_t[$];
  Cage166 #(int) cage166;
  initial begin
    modQ166_t mqVal166;
    pkgQ166_t mpqVal166;
    mqVal166 = '{1};
    mpqVal166 = '{2};
    if (mqVal166.size() != mpqVal166.size()) $display("x");
  end
endmodule
