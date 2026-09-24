// b1_scope — AXIS 1: the SCOPE the call sits in.  The SAME call
// `rep60("i", "m", 1)` (bare decimal `1` on a `bit` formal), written with NO
// macro anywhere, from every scope the emitter can reach:
//   S1 class method (in a package)      S5 class constructor `new`
//   S2 package function                 S6 class STATIC method
//   S3 module function                  S7 out-of-body extern class method
//   S4 module always block              S8 class method in a $unit class
package p61;
   function void rep60(string id, string message, bit flag = 0);
   endfunction

   // S2 — package function
   function void s2_pkgfunc();
      rep60("s2", "m", 1);
   endfunction

   class c61;
      int m;
      // S1 — class method
      function void s1_method();
         rep60("s1", "m", 1);
      endfunction
      // S5 — constructor
      function new();
         rep60("s5", "m", 1);
      endfunction
      // S6 — static method
      static function void s6_static();
         rep60("s6", "m", 1);
      endfunction
      // S7 — extern, defined out of body
      extern function void s7_extern();
   endclass

   function void c61::s7_extern();
      rep60("s7", "m", 1);
   endfunction
endpackage

class c62;                       // S8 — $unit-scope class
   function void s8_unit();
      p61::rep60("s8", "m", 1);
   endfunction
endclass

module b1_scope;
   import p61::*;
   // S3 — module function
   function void s3_modfunc();
      rep60("s3", "m", 1);
   endfunction

   initial begin
      s3_modfunc();
   end

   // S4 — module always block
   logic clk;
   always @(posedge clk) begin
      rep60("s4", "m", 1);
   end
endmodule
