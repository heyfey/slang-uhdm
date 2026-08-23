// r10uvm107 arm a3 — THE OWNER GRID: WHICH module receives the minted wire when
// SEVERAL import the package, and what the wire carries.  MEASUREMENT ONLY.
// The reference is written one CONTROL BODY deeper than its declaration, which
// is the position arm a1 measured as golden's `logic_net` cell, so the law is
// live here; three modules import the package (two of them TOPS) and one does
// not.
package r107;
  class base107;
    int fld;
  endclass
  class holder107 #(type ET = base107);
    base107 anchor;
    extern function void deep107();
    extern task         deeptask107();
  endclass
  function void holder107::deep107();
    ET e1;
    if (anchor != null) begin
      eat107(e1);
      eat107(e1);
    end
  endfunction
  task holder107::deeptask107();
    ET t1;
    if (anchor != null) begin
      eat107(t1);
    end
  endtask
  function void eat107(base107 v); endfunction
endpackage

module firsttop107;
  import r107::*;
  holder107 #(base107) h1;
  initial h1 = new();
endmodule

module secondtop107;
  import r107::*;
  holder107 #(base107) h2;
  initial h2 = new();
endmodule

module childmod107;
  import r107::*;
  holder107 #(base107) h3;
  initial h3 = new();
endmodule

module thirdtop107;
  childmod107 kid();
endmodule

module noimport107;
  int only107;
  initial only107 = 2;
endmodule
