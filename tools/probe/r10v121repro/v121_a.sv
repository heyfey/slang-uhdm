// r10uvm121 VERIFIER arm A — KEPT-SLOT shapes the implementer's g121_a never
// varied: dynamic-array new in a KEPT slot, super. + new[], the copy-array
// form, a DEEPER this path, `this.super.`, an IN-BODY constructor, repeat /
// forever / do-while / else bodies, the SAME statement twice in one body, and
// named-argument new.  Names deliberately unrelated to g121_a's vocabulary.
package bellows;

class Ember;
   int glow;
   function new(int spark = 0); glow = spark; endfunction
endclass

class Cinder;
   Ember core;
   Ember shell;
   function new(int spark = 7); core = new(spark); endfunction
endclass

class Forge;
   Ember anvil;
   Ember tongs;
   Ember quench;
   Ember bellow;
   Ember slag;
   Ember dross;
   Ember flux;
   Cinder clinker;
   Ember heap[];
   Ember pile[];
   int temper;
   int rods[2];
   // IN-BODY constructor with a port list (R-ctorshift121 keeps the port list)
   function new(int seed);
      temper        = seed;              // A01 control plain
      this.heap     = new[4];            // A02 KEPT slot + new[N]   <-- untested by g121_a
      this.anvil    = new;               // A03 KEPT slot bare new (in-body ctor)
      this.anvil    = new;               // A04 THE SAME SHAPE TWICE in one body
      this.pile     = new[2];            // A05 KEPT slot + new[N] again
      this.tongs    = new(.spark(3));    // A06 named argument
      this.clinker  = new(5);            // A07 a class whose own ctor assigns
      this.quench   = new this.anvil;    // A08 copy form, kept slot
      this.clinker.core = new;           // A09 DEEPER this path, kept slot
      this.slag     = new(temper);       // A10 arg reads a local property
   endfunction

   function void hammer(int n);
      repeat (n)
         this.bellow = new;              // A11 sole body of a repeat
      do
         this.dross = new(2);            // A12 sole body of a do-while
      while (n == 99);
      if (n == 1)
         temper = 1;
      else
         this.flux = new;                // A13 sole body of an ELSE
      case (n)
         2, 3:  this.anvil = new;        // A14 multi-label case_item
         default: this.tongs = new;      // A15 the DEFAULT case_item
      endcase
      foreach (rods[i])
         this.heap = new[i];             // A16 foreach body + new[N]
   endfunction
endclass

class Crucible extends Forge;
   Ember lip;
   Ember rim;
   function new(int seed);
      super.new(seed);
      super.heap  = new[3];              // A17 super. + new[N]   <-- untested
      super.anvil = new;                 // A18 super. bare, in-body derived ctor
      this.lip    = new;                 // A19 this. in derived in-body ctor
      this.super.tongs = new;            // A20 `this.super.` implicit class handle
      this.rim    = new(4);
   endfunction
endclass

endpackage

module bellows_top;
  import bellows::*;
  Forge f;
  Crucible c;
  initial begin
    f = new(1);
    c = new(2);
    f.hammer(3);
  end
endmodule
