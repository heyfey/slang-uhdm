// vbuvm15 VERIFIER ARM 1 — § retNameRecvCollapseArgsBindLikeBody15 in EVERY
// HOME the brief names, and with every ARGUMENT SHAPE the implementer's a1/a2
// left unmeasured (this.x / super.x / enum constant / parameter / OPERATION
// operands / CONCAT operands / nested call / string literal / output+ref
// formals / a DEFAULTED formal / a TASK method).
// One question per cell: does golden give the ref a vpiActual, and do we?
class ucls15;                       // $unit-scope class
   int up;
   function void uone(int a); up = a; endfunction
endclass
// $unit-scope function whose return variable is the receiver (unitSubNoBind9).
function automatic ucls15 ufn15(int uf1);
   int uloc = 1;
   ufn15 = new();
   ufn15.uone(uf1);                 // u10 $unit function, FORMAL
   ufn15.uone(uloc);                // u11 $unit function, body LOCAL
endfunction

package pv15;
   int pkgv15 = 1;
   typedef enum int {EA15 = 0, EB15 = 1} e15_t;
   parameter int PP15 = 5;

   class hlp15;
      int hp;
      function void one(int a); hp = a; endfunction
      function void two(int a, int b); hp = a + b; endfunction
      function void ones(string s); hp = s.len(); endfunction
      function void outp(output int o); o = 1; endfunction
      function void refp(ref int r); r = r + 2; endfunction
      function void dflt(int a, int b = 3); hp = a + b; endfunction
      task tone(int a); hp = a; endtask
      function int getv(); return hp; endfunction
   endclass

   class base15;
      int bprop15 = 4;
   endclass

   function automatic int rec15(int r1);
      if (r1 <= 0) return 0;
      return rec15(r1 - 1);
   endfunction

   class der15 extends base15;
      int dprop15 = 5;
      e15_t ev15 = EB15;

      // VIRTUAL in-body method.
      virtual function hlp15 vmk15(int f1);
         int loc15 = 6;
         vmk15 = new();
         vmk15.one(f1);              // v10 virtual, FORMAL
         vmk15.one(loc15);           // v11 virtual, body LOCAL
         vmk15.one(this.dprop15);    // v12 this.<prop>
         vmk15.one(super.bprop15);   // v13 super.<prop>
         vmk15.one(EA15);            // v14 ENUM constant
         vmk15.one(PP15);            // v15 PARAMETER
         vmk15.one(f1 + loc15);      // v16 OPERATION operands
         vmk15.one({f1[0], loc15[0]}); // v17 CONCAT operands
         vmk15.two(f1, loc15);       // v18 two refs
         vmk15.one(rec15(f1));       // v19 NESTED call argument
         vmk15.ones("lit15");        // v20 string literal
         vmk15.outp(loc15);          // v21 OUTPUT formal
         vmk15.refp(loc15);          // v22 REF formal
         vmk15.dflt(f1);             // v23 DEFAULTED formal not written
         // v24 REMOVED: a task cannot be invoked from a function (slang error)
         vmk15.one(vmk15.getv());    // v25 nested call ON the return variable
      endfunction

      // Plain in-body method calling ITSELF recursively as a plain call, in the
      // same body as a collapsed one (the census's own control family).
      function hlp15 rmk15(int f2);
         int rloc15 = 7;
         rmk15 = new();
         rmk15.one(f2);              // v30 collapsed, FORMAL
         void'(rmk15b(f2, rloc15));  // v31 CONTROL ordinary in-body call
      endfunction
      function int rmk15b(int a, int b); return a + b; endfunction
   endclass
endpackage

// A MODULE-scope function (si=1, no classMethodNoBind).
module m15;
   import pv15::*;
   function automatic hlp15 mfn15(int a1);
      int mloc15 = 8;
      mfn15 = new();
      mfn15.one(a1);                 // m10 MODULE function, FORMAL
      mfn15.one(mloc15);             // m11 MODULE function, body LOCAL
   endfunction
   der15 d;
   ucls15 u;
   initial begin
      d = new();
      void'(d.vmk15(1));
      void'(d.rmk15(2));
      void'(mfn15(3));
      u = ufn15(4);
   end
endmodule
