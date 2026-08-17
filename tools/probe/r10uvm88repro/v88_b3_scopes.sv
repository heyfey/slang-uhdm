// v88 b3 — WHERE THE CLASS LIVES.  $unit class, module class, interface class,
// NESTED class, a class in another package EXTENDING one in p3.
package p3;
  const string c3 = "C3";
  int          n3 = 3;
  class base3;
    string s; int i;
    function void inb_base();  s = c3; i = n3; endfunction
    class nested3;                          // NESTED class, in-body method
      string t;
      function void inb_nested(); t = c3; endfunction
    endclass
    extern function void oob_base();
  endclass
  function void base3::oob_base(); s = c3; i = n3; endfunction
endpackage

package r3;
  import p3::*;
  class der3 extends base3;                 // DERIVED, other package
    function void inb_der();  s = c3; i = n3; endfunction
  endclass
endpackage

// $unit-scope class reading p3
import p3::*;
class unitc3;
  string s; int i;
  function void inb_unit(); s = c3; i = n3; endfunction
endclass

interface if3;
  import p3::*;
  class ifc3;
    string s;
    function void inb_if(); s = c3; endfunction
  endclass
endinterface

module topb3;
  import p3::*;
  class modc3;                              // MODULE-scope class
    string s; int i;
    function void inb_mod(); s = c3; i = n3; endfunction
  endclass
  p3::base3 b; r3::der3 d; unitc3 u; modc3 mc;
  task mt3(); automatic string t; t = c3; t = p3::c3; endtask
  initial begin
    b = new(); d = new(); u = new(); mc = new();
    b.inb_base(); d.inb_der(); u.inb_unit(); mc.inb_mod(); mt3();
  end
endmodule
