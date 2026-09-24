// g1 — THE CORE CELL.  A package variable whose initialiser is a BARE REFERENCE
// to another variable of the same package, wildcard-imported into a package that
// declares a class.  SeqDriver's `uvm_printer uvm_default_printer =
// uvm_default_table_printer;` at its smallest.  The scored cell is the CLASS
// listing's copy of `b1`: what is its initialiser ref's vpiFullName, and what
// does its vpiActual point at?
package p1;
  int a1 = 1;
  int b1 = a1;
endpackage
package q1;
  import p1::*;
  class c1;
    int own1;
  endclass
endpackage
module m1;
  q1::c1 h1;
endmodule
