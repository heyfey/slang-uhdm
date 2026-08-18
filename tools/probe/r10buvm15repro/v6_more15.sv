// vbuvm15 VERIFIER ARM 6 — the remaining homes and argument shapes.
// $unit-scope CLASS method, fork/join bodies, a STATIC class property, a
// STRUCT member, an ARRAY element, a class-STATIC variable, a do/while and a
// foreach body, and a collapsed call whose argument is a CHAINED member.
class uc15;                          // $unit-scope CLASS
   int up15 = 1;
   static int us15 = 2;
   function void one(int a); up15 = a; endfunction
   function uc15 umk15(int f1);
      int uloc15 = 3;
      umk15 = new();
      umk15.one(f1);                 // x10 $unit CLASS method, FORMAL
      umk15.one(uloc15);             // x11 $unit CLASS method, body LOCAL
      umk15.one(us15);               // x12 $unit CLASS method, STATIC property
   endfunction
endclass

package px15;
   typedef struct packed { int a; int b; } s15_t;
   class hx15;
      int hp;
      function void one(int a); hp = a; endfunction
   endclass
   class cx15;
      static int sprop15 = 4;
      s15_t st15;
      int arr15[4];

      function hx15 mkx15(int f1);
         int loc15 = 5;
         s15_t lst15;
         int larr15[4];
         mkx15 = new();
         mkx15.one(sprop15);         // x20 class STATIC property
         mkx15.one(st15.a);          // x21 class-property STRUCT member
         mkx15.one(lst15.b);         // x22 LOCAL struct member
         mkx15.one(arr15[1]);        // x23 class-property ARRAY element
         mkx15.one(larr15[f1]);      // x24 LOCAL array element, ref INDEX
         fork
            mkx15.one(f1);           // x25 inside FORK
            mkx15.one(loc15);        // x26 inside FORK, body local
         join_none
         do begin
            mkx15.one(loc15);        // x27 DO-WHILE body
         end while (0);
         foreach (larr15[i]) begin
            mkx15.one(larr15[i]);    // x28 FOREACH body, loop index
         end
         forever begin
            mkx15.one(f1);           // x29 FOREVER body
            break;
         end
      endfunction

      // AUTOMATIC in-body method (the default for a class method is automatic;
      // written out so the axis is explicit).
      function automatic hx15 amk15(int a1);
         int aloc15 = 6;
         amk15 = new();
         amk15.one(a1);              // x30 AUTOMATIC, FORMAL
         amk15.one(aloc15);          // x31 AUTOMATIC, body LOCAL
      endfunction
   endclass
endpackage

module mx15;
   import px15::*;
   cx15 c;
   uc15 u;
   initial begin
      c = new();
      u = new();
      void'(c.mkx15(1));
      void'(c.amk15(2));
      void'(u.umk15(3));
   end
endmodule
