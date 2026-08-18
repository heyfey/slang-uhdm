// vbuvm15 VERIFIER ARM 2 — SHADOWING, DEPTH and the BUILT-IN collapse arm's
// unmeasured shapes.  A local named like a formal (block-scope shadow), a
// formal named like a PACKAGE variable, a collapsed call under a NAMED block,
// under a for/while body, in an else-begin, and the built-in arm with
// operation / concat / nested-call / this.prop / super.prop arguments.
package ps15;
   int shadow15 = 11;
   typedef int iq15[$];
   class bs15;
      int bp15 = 12;
   endclass
   class hh15;
      int hp15;
      function void one(int a); hp15 = a; endfunction
   endclass

   class sh15 extends bs15;
      int cp15 = 13;

      // A FORMAL named exactly like the PACKAGE variable.
      function hh15 fshad15(int shadow15);
         hh15 tmp;
         fshad15 = new();
         fshad15.one(shadow15);      // s10 formal SHADOWING a package var
      endfunction

      // A BLOCK LOCAL named exactly like the enclosing FORMAL.
      function hh15 bshad15(int a15);
         bshad15 = new();
         bshad15.one(a15);           // s20 the FORMAL itself, depth 0
         begin
            int a15 = 14;            // shadows the formal
            bshad15.one(a15);        // s21 the BLOCK LOCAL shadow, same depth
         end
      endfunction

      // Control-depth axis beyond the implementer's single if-begin cell.
      function hh15 dep15(int d1);
         int dloc15 = 15;
         dep15 = new();
         if (d1 == 0) begin
            dep15.one(d1);           // s30 IF-begin (control)
         end
         else begin
            dep15.one(dloc15);       // s31 ELSE-begin
         end
         for (int i = 0; i < 2; i++) begin
            dep15.one(d1);           // s32 FOR body
         end
         while (d1 > 100) begin
            dep15.one(dloc15);       // s33 WHILE body
         end
         nb15: begin
            int nloc15 = 16;
            dep15.one(nloc15);       // s34 NAMED block local
            dep15.one(d1);           // s35 NAMED block, formal
         end
         case (d1)
           0: dep15.one(d1);         // s36 CASE arm
           default: dep15.one(dloc15); // s37 CASE default arm
         endcase
      endfunction

   endclass
endpackage

module ms15;
   import ps15::*;
   sh15 s;
   initial begin
      s = new();
      void'(s.fshad15(1));
      void'(s.bshad15(2));
      void'(s.dep15(3));
   end
endmodule
