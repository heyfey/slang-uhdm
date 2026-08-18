// vbuvm15 VERIFIER ARM 4 — SITE 2 (the BUILT-IN collapse arm) on a return type
// Surelog compiles WITHOUT a CP0332 error.  a2_collbuiltin15.sv exercises SITE 2
// only through `<queue-return>.push_back(...)`, which Surelog flags
// `[ERR:CP0332] Function "push_back" is not defined for variable ... of type
// iq15` on every one of its class-method cells — the golden those cells are
// measured against is an ERROR-PATH golden.  A STRING return variable takes the
// same collapse (UVM's own `index_string.itoa(index);`) and parses clean.
package pb15;
   int pkgb15 = 21;
   class bb15;
      int bbp15 = 22;
   endclass
   class sb15 extends bb15;
      int cbp15 = 23;

      function string mks15(int f1);
         int loc15 = 24;
         mks15 = "";
         mks15.itoa(f1);              // b10 built-in collapse, FORMAL
         mks15.itoa(loc15);           // b11 built-in collapse, body LOCAL
         mks15.itoa(cbp15);           // b12 built-in collapse, class PROPERTY
         mks15.itoa(pkgb15);          // b13 built-in collapse, PACKAGE var
         mks15.itoa(f1 + loc15);      // b14 built-in collapse, OPERATION
         mks15.itoa(this.cbp15);      // b15 this.<prop>
         mks15.itoa(super.bbp15);     // b16 super.<prop>
         mks15.itoa(idb15(f1));       // b17 NESTED call
         if (f1 != 0) begin
            mks15.itoa(f1);           // b18 built-in collapse, IF-begin
         end
      endfunction

      static function string smks15(int s1);
         int sloc15 = 25;
         smks15 = "";
         smks15.itoa(s1);             // b20 STATIC in-body
         smks15.itoa(sloc15);         // b21 STATIC in-body, body local
      endfunction

      function int idb15(int x); return x; endfunction
      extern function string oobs15(int o1);
   endclass

   function string sb15::oobs15(int o1);
      int oloc15 = 26;
      oobs15 = "";
      oobs15.itoa(o1);                // b30 OUT-OF-BODY (gate b: no collapse)
      oobs15.itoa(oloc15);            // b31 OUT-OF-BODY
   endfunction

   function automatic string pkgs15(int p1);
      int ploc15 = 27;
      pkgs15 = "";
      pkgs15.itoa(p1);                // b40 PACKAGE function (si=1 control)
      pkgs15.itoa(ploc15);            // b41 PACKAGE function, body local
   endfunction
endpackage

module mb15;
   import pb15::*;
   sb15 s;
   initial begin
      s = new();
      $display(s.mks15(1), sb15::smks15(2), s.oobs15(3), pkgs15(4));
   end
endmodule
