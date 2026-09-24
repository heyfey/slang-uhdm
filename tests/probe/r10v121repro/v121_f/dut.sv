// r10uvm121 VERIFIER arm F — statement CONTEXTS that wrap a blocking assignment
// in another production: an ASSERT action block (pass and fail arms), an
// EVENT-CONTROLLED statement, a WAIT body, a DISABLE-guarded block, a path
// through an ARRAY ELEMENT then a member, and a `super.` write reaching a base
// class imported from ANOTHER package.
package moraine;
   class Talus;
      int scree;
      function new(int s = 0); scree = s; endfunction
   endclass
   class Esker;
      Talus kame;
      Talus drumlin;
      function new(int s); kame = new(s); endfunction
   endclass
endpackage

package outwash;
   import moraine::*;

   class Kettle;
      Talus boulder;
      Talus cobble;
      Talus pebble;
      Talus gravel;
      Talus sand;
      Esker ridge[2];
      int silt;

      function new(int s);
         silt = s;
         this.ridge[0] = new(s);            // F01 kept slot, ARRAY-ELEMENT lvalue
      endfunction

      task settle(int k);
         assert (k > 0)
            this.boulder = new;             // F02 ASSERT pass action
         else
            this.cobble = new;              // F03 ASSERT fail action
         @(silt)
            this.pebble = new;              // F04 under an EVENT control
         wait (k == 4)
            this.gravel = new;              // F05 a WAIT body
         if (k == 5)
            this.ridge[1].kame = new;       // F06 array element THEN member
      endtask
   endclass

   class Delta extends Kettle;
      Talus loam;
      function new(int s);
         super.new(s);
         super.sand = new;                  // F07 super. reaching a CROSS-PACKAGE base
         this.loam  = new(2);
      endfunction
   endclass
endpackage

module moraine_top;
  import outwash::*;
  Kettle kt;
  Delta  dl;
  initial begin
    kt = new(1);
    dl = new(2);
  end
endmodule
