// r10uvm121 VERIFIER arm C — THE NEGATIVE CONTROLS.  Every shape that LOOKS
// like the law but must NOT be emptied, plus the shapes the predicate
// deliberately declines.  If any of these changes between the two binaries the
// predicate is over-firing.
package smithy;

class Rivet;
   int shank;
   function new(int s = 0); shank = s; endfunction
   function Rivet clone(); clone = new(shank); endfunction
endclass

class Plate;
   Rivet stud;
   Rivet boss;
   Rivet lug;
   Rivet peg[];
   Rivet ring[string];
   int gauge;
   int newton;              // an identifier that merely CONTAINS "new"
   Rivet renewal;           // ditto
   static Rivet shared_stud;

   function new(int g);
      gauge          = g;
      stud           = new(1);        // C01 BARE property + new  -> must stay FULL
      this.gauge     = g + 1;         // C02 this. + non-new      -> FULL
      this.boss      = stud;          // C03 this. + plain handle -> FULL
      this.lug       = stud.clone();  // C04 this. + method call  -> FULL
      this.renewal   = new(2);        // C05 this. + new, name contains "new" -> EMPTY
      newton         = 3;             // C06 control
   endfunction

   function void press(int k);
      Plate other;
      other = new(k);
      if (k == 1)
         other.stud = new;            // C07 ANOTHER object's property -> FULL
      if (k == 2)
         this.peg[0] = new;           // C08 this. + INDEX select     -> declined
      if (k == 3)
         this.ring["a"] = new;        // C09 this. + assoc select     -> declined
      if (k == 4)
         this.gauge += 1;             // C10 compound                 -> declined
      if (k == 5)
         this.stud = new;             // C11 the LAW: sole if branch  -> EMPTY
      if (k == 6)
         gauge = k;
   endfunction

   task poke(int k);
      if (k == 7)
         this.boss <= stud;           // C12 NONBLOCKING this. handle -> declined
      if (k == 8)
         #1 this.gauge = k;           // C13 delayed this. assignment -> declined
   endtask
endclass

endpackage

module smithy_top;
  import smithy::*;
  Plate p;
  initial begin
    p = new(1);
    p.press(5);
  end
endmodule
