// r10uvm121 VERIFIER arm H — ROBUSTNESS: `this`/`super`-rooted `= new` forms
// whose ARGUMENTS or TARGETS slang cannot fully bind, plus a `super.` in a class
// with no base and a `this.` in a class with no such property.  Neither binary
// may crash; both must behave the same way.
package brine;
class Salt;
   int grain;
   function new(int g = 0); grain = g; endfunction
endclass
class Vat;
   Salt crust;
   Salt rime;
   Salt lees;
   int lye;
   function new(int l);
      lye        = l;
      this.crust = new(undeclared_thing);   // H01 unbindable argument
      this.rime  = new(lye, 2, 3, 4);       // H02 too many arguments
      this.lees  = new;
   endfunction
   function void boil();
      this.crust = new(this.lees);          // H03 wrong-typed argument
   endfunction
endclass
endpackage
module brine_top;
  import brine::*;
  Vat v;
  initial v = new(1);
endmodule
