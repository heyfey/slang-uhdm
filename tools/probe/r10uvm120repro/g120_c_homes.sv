// r10uvm120 arm c: the HOME/VIEW face — which enclosing scope's return window
// substitutes.  A module function, a $unit function, an in-body class method,
// an out-of-body class method written at package scope, and a wildcard-import
// clone of a package function.
parameter int UK = 6;
function int uf120c();  return UK;  endfunction

package p120c1;
  parameter int PK = 4;
  parameter string PS = "pk";

  function int pf();        return PK; endfunction

  class c120c;
    function int inbody();  return PK; endfunction
    extern function int oob();
    extern function string oobs();
  endclass

  function int c120c::oob();      return PK; endfunction
  function string c120c::oobs();  return PS; endfunction
endpackage

package p120c2;
  import p120c1::*;
  parameter int QK = 9;
  function int qf();  return QK; endfunction
endpackage

module m120c;
  parameter int MK = 3;
  function int mf();  return MK; endfunction
  initial $display(mf(), uf120c(), p120c1::pf(), p120c2::qf());
endmodule
