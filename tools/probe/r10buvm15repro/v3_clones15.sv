// vbuvm15 VERIFIER ARM 3 — buvm13's CLONE FENCE.  The same package class is
// reached through a WILDCARD import, an EXPLICIT import and a fully qualified
// name, in three separate modules, so the emitter builds a clone of the class
// definition per importing scope.  A law that binds through the wrong clone
// shows up here as a differing actual.
package pc15;
   class ch15;
      int cp;
      function void one(int a); cp = a; endfunction
   endclass
   class mk15c;
      int prop15 = 1;
      function ch15 mkw15(int w1);
         int wloc15 = 2;
         mkw15 = new();
         mkw15.one(w1);              // w10 formal, through every import form
         mkw15.one(wloc15);          // w11 body local
         mkw15.one(prop15);          // w12 class property (stays bare)
      endfunction
   endclass
endpackage

module wild15;                        // WILDCARD import
   import pc15::*;
   mk15c m;
   initial begin m = new(); void'(m.mkw15(1)); end
endmodule

module expl15;                        // EXPLICIT import
   import pc15::mk15c;
   import pc15::ch15;
   mk15c m;
   initial begin m = new(); void'(m.mkw15(2)); end
endmodule

module qual15;                        // fully QUALIFIED, no import
   pc15::mk15c m;
   initial begin m = new(); void'(m.mkw15(3)); end
endmodule
