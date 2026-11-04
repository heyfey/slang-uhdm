// § assocBracketPkgOnly186 (control: a package class keeps § assocPromotedBoundAtBracket183)
package p;
class e; endclass
class c;
  extern function void f();
endclass
function void c::f();
   bit m[e];
   int idx;
   idx = 1;
endfunction
endpackage
module top; endmodule
