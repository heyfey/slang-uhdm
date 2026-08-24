// vb32r3 — the REACHABILITY frontier of the registration key, measured on
// golden so the verifier's clause is neither too narrow nor too wide.
//   D1  an out-of-body registration in an UNIMPORTED package, aliased by a
//       typedef of the SAME text in another package: Surelog's search never
//       reaches a package it does not access -> golden must DEGRADE.
//   D2  the same shape where the decoy package IS wildcard-imported.
//   D3  a package free function twin for an IN-BODY class method.
package pdec32;                       // the decoy: never imported by pcall32
  class twin32;
    static int w32;
    extern static function void dfn32(int a);
  endclass
  function void pdec32_unused32(); endfunction
  function void twin32::dfn32(int a); w32 += a; endfunction
endpackage

package pimp32;                       // the decoy that IS imported
  class twin2_32;
    static int w2_32;
    extern static function void dfn2_32(int a);
  endclass
  function void twin2_32::dfn2_32(int a); w2_32 += a; endfunction
endpackage

package pcall32;
  import pimp32::*;
  class real32;
    typedef real32 twin32;            // shadows pdec32::twin32's TEXT
    typedef real32 twin2_32;          // shadows pimp32::twin2_32's TEXT
    static int r32;
    extern static function void dfn32(int a);
    extern static function void dfn2_32(int a);
    static function void inbtwin32(int a); r32 += a; endfunction
    extern static function void run32();
  endclass
  function void real32::dfn32(int a); r32 += a; endfunction
  function void real32::dfn2_32(int a); r32 += a; endfunction
  function void inbtwin32(int a); endfunction   // package FREE twin of an IN-BODY method
  function void real32::run32();
    twin32::dfn32(1);        // D1 decoy in an UNIMPORTED package
    twin2_32::dfn2_32(2);    // D2 decoy in an IMPORTED package
    real32::dfn32(3);        // D0 control -> call
  endfunction
endpackage

module vb32r3;
  initial begin
    pcall32::real32::run32();
    pcall32::real32::inbtwin32(4);  // D3 pkg free twin of an IN-BODY method
  end
endmodule
