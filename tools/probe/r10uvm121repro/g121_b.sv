// r10uvm121 arm b — the FENCE.  Slots where § thisSuperNewAssignNoStmt3
// DROPS the statement (so this pass must change nothing), the `::`-scoped
// prefixes, and the negative controls.  Names, orders and shapes deliberately
// unrelated to arm a's.
package tallow;

typedef class Wick;

class Wick;
   int burn;
   function new(int heat = 1); burn = heat; endfunction
endclass

class Taper;
   Wick snuff;
   Wick douse;
   Wick guttering;
   Wick sconce;
   Wick cresset;
   static Wick shared_wick;
   Wick pool[];
   Wick basin[string];
   int wax;
   function void trim();                    // in-body, NOT a constructor
      this.snuff = new;                     // b01 begin-list element -> DROPPED
      wax = 1;
      this.douse = new this.snuff;          // b02 copy form in a begin list
      wax = 2;
   endfunction
   function void wane();
      this.guttering = new;                 // b03 WHOLE body of a plain function
   endfunction
   function void dip();
      this.pool = new[4];                   // b04 dynamic-array new, begin list
      wax = 3;
   endfunction
   task snuffer(int r);
      fork
         this.sconce = new;                 // b05 a fork arm
      join
      begin : lit
         this.cresset = new;                // b06 a NAMED begin
      end
      for (int q = 0; q < r; q++)
         this.snuff = new;                  // b07 sole body of a for
   endtask
   function void scope_forms();
      Taper::shared_wick = new;             // b08 class_scope prefix
      tallow::free_wick  = new;             // b09 package_scope prefix
      this.basin["lamp"] = new;             // b10 this. + associative select
      this.pool[1]       = new;             // b11 this. + index select
      douse              = new;             // b12 control: bare property
      pool[2]            = new;             // b13 control: bare + index
   endfunction
endclass

Wick free_wick;
Wick tallow_probe;

endpackage

module tallow_top;
  import tallow::*;
  Taper t;
  initial begin
    t = new();
    t.trim();
  end
endmodule
