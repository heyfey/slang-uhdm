// r10uvm121 VERIFIER arm E — the remaining unvaried axes: the ARRAY-COPY form
// `new[n](src)`, a STATIC property written through `this.`, a class inside an
// INTERFACE and inside a PROGRAM, a VIRTUAL method's kept slot, an EVENT-
// CONTROLLED and a DELAYED `this.` assignment, and a `this.` write in a task
// under `@`.  Vocabulary unrelated to every earlier arm.
package tundra;

class Floe;
   int drift;
   function new(int d = 0); drift = d; endfunction
endclass

class Pack;
   Floe berg;
   Floe crag;
   Floe shelf;
   Floe ridge;
   Floe lead[];
   Floe seam[];
   static Floe rime;
   int frost;

   function new(int f);
      frost      = f;
      this.lead  = new[3];               // E01 kept slot, new[N]
      this.seam  = new[2](this.lead);    // E02 kept slot, ARRAY-COPY new[n](src)
      this.rime  = new(1);               // E03 kept slot, STATIC property via this.
      this.berg  = new(f);
   endfunction

   virtual function void calve(int k);
      if (k == 1)
         this.crag = new;                // E04 VIRTUAL method, sole if branch
      while (k == 2)
         this.lead  = new[k];            // E05 VIRTUAL method, while + new[N]
   endfunction

   task freeze(int k);
      if (k == 3)
         #2 this.frost = k;              // E06 DELAYED this. non-new  (declined)
      if (k == 4)
         this.ridge = new;               // E07 kept slot inside a TASK
   endtask
endclass

class Growler extends Pack;
   Floe bergy;
   function new(int f);
      super.new(f);
      this.bergy = new;                  // E08 derived ctor
   endfunction
   virtual function void calve(int k);
      super.calve(k);
      if (k == 9)
         super.crag = new;               // E09 super. inside an override
   endfunction
endclass

endpackage

interface tundra_if;
  import tundra::*;
  class Watcher;
     Floe eddy;
     function new();
        this.eddy = new(4);              // E10 class inside an INTERFACE
     endfunction
  endclass
  Watcher w;
  initial w = new();
endinterface

program tundra_prog;
  import tundra::*;
  class Logger;
     Floe note;
     function new();
        this.note = new(5);              // E11 class inside a PROGRAM
     endfunction
  endclass
  Logger lg;
  initial lg = new();
endprogram

module tundra_top;
  import tundra::*;
  tundra_if tif();
  Pack p;
  Growler g;
  initial begin
    p = new(1);
    g = new(2);
    g.calve(1);
  end
endmodule
