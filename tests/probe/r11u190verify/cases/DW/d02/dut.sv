// § doWhileSyntaxFromCond181 (r11u190: the parameterized class with the do-while declaring a local comes from an INCLUDED file)
package p;
  class tok; static function tok mk(); mk = new(); endfunction endclass
`include "cls.svh"
endpackage
module top;
endmodule
