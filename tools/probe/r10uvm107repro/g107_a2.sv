// r10uvm107 arm a2 — THE OWNER GRID: which module receives the minted wire, and
// what the wire carries.  MEASUREMENT ONLY.
// Two package classes, TWO tops, a module that imports the package only at FILE
// scope, a module that imports it inside its own body, and a module that does
// not import it at all.  Also: an UNDECLARED identifier in an in-body method and
// in a module initial block, the two families the brief asks to separate from
// this law.
package q107b;
  class base107;
    int   fld;
    function int mm(int a); return a; endfunction
  endclass
  class carrier107 #(type ET = base107);
    base107 anchor;
    extern function void oob_two();
    extern task         oob_task();
  endclass
  function void carrier107::oob_two();
    ET e1;
    ET e2;
    consume107(e1);
    consume107(e2);
    consume107(e1);
  endfunction
  task carrier107::oob_task();
    ET tv;
    consume107(tv);
  endtask
  function void consume107(base107 v); endfunction
endpackage

// A module whose ONLY import is at FILE scope (the SimpleUVM shape).
import q107b::*;
module modimp107a;
  carrier107 #(base107) c1;
  initial c1 = new();
endmodule

// A module with its OWN body-scope import.
module modimp107b;
  import q107b::*;
  carrier107 #(base107) c2;
  initial c2 = new();
endmodule

// A module that imports NOTHING and declares no wires.
module modnoimp107;
  int local107;
  initial local107 = 1;
endmodule

// NOTE the UNDECLARED-identifier separator (`seen107 = undeclared107;` in a
// module body) is NOT in this arm: slang REJECTS the whole file for it
// (`use of undeclared identifier`), so an arm carrying it would produce no
// database on our side at all and the grid cell would be unmeasurable.  That
// family (§ implicitNet for an undeclared name) is a DIFFERENT law and is
// recorded as a residue instead.
