// § pkgVarLvalueScopeSep292
package p; int q; string s; endpackage
package r;
  class outer;
    class inner;
      task t(); p::q = 3; p::s = "x"; endtask
    endclass
    function new(); p::q = 1; endfunction
  endclass
  class d extends outer;
    static function void sf(); p::q = 9; endfunction
  endclass
endpackage
module top; endmodule
