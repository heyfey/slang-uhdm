// r10v140 arm T — DECLARATION ORDER is what the pristine bug keyed on, so this
// arm varies it: the used alias declared LAST, declared FIRST, and in between;
// four aliases over one canonical enum; a forward typedef; an alias whose base
// is itself an alias declared after another alias; a type PARAMETER return.
package Cinder_pkg;
  typedef struct packed { bit [1:0] ash; } cinderWord;      // decoy, same shape
  typedef struct packed { bit [1:0] ash; } cinderTwin;      // distinct canonical
  typedef enum bit [3:0] { CIN_A = 1, CIN_B = 2, CIN_C = 4, CIN_D = 8 } sparkLevel;
  typedef sparkLevel alphaSpark;      // 1st alias
  typedef sparkLevel BetaSpark_e;     // 2nd alias
  typedef sparkLevel gamma_spark_t;   // 3rd alias
  typedef alphaSpark deltaOfAlpha;    // alias of the 1st alias
  typedef cinderWord CinderWord_s;
  typedef cinderTwin cinder_twin_alias;

  class Grate;
    // return the 3rd alias, the 2nd, the alias-of-alias, the 1st, and the base
    function gamma_spark_t useThird(); return CIN_C; endfunction
    function BetaSpark_e useSecond(); return CIN_B; endfunction
    function deltaOfAlpha useDelta(); return CIN_D; endfunction
    function alphaSpark useFirst(); return CIN_A; endfunction
    function sparkLevel useBase(); return CIN_A; endfunction
    function CinderWord_s useWordAlias(); CinderWord_s w; return w; endfunction
    function cinder_twin_alias useTwinAlias(); cinder_twin_alias t; return t; endfunction
    function cinderWord useWordBase(); cinderWord w; return w; endfunction
  endclass
endpackage

package Soot_pkg;
  typedef enum bit [2:0] { SOOT_DRY = 1, SOOT_WET = 2 } sootGrade;
  class Flue;
    typedef sootGrade FlueGrade_e;              // class-scope alias
    typedef Cinder_pkg::sparkLevel FlueSpark_e; // class-scope alias of another pkg's typedef
    FlueGrade_e held;
    function FlueGrade_e clsAliasGrade(); return held; endfunction
    function sootGrade clsBaseGrade(); return held; endfunction
    function FlueSpark_e clsForeignAlias(); return Cinder_pkg::CIN_B; endfunction
    function Cinder_pkg::sparkLevel clsForeignBase(); return Cinder_pkg::CIN_A; endfunction
  endclass
  typedef sootGrade lateGrade_t;   // alias declared AFTER the class that used the base
  function lateGrade_t pkgLateAlias(); return SOOT_DRY; endfunction
endpackage

class Chimney #(type ST = Cinder_pkg::BetaSpark_e);
  ST perched;
  function ST paramReturn(); return perched; endfunction
  function Cinder_pkg::alphaSpark concreteReturn(); return Cinder_pkg::CIN_A; endfunction
endclass

module cinder_top;
  Cinder_pkg::Grate gr;
  Soot_pkg::Flue fl;
  Chimney #(Cinder_pkg::gamma_spark_t) ch_g;
  Chimney #(Cinder_pkg::sparkLevel)    ch_b;
  Chimney                              ch_d;
  Soot_pkg::lateGrade_t lg;
  initial lg = Soot_pkg::pkgLateAlias();
endmodule
