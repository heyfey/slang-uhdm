// vbuvm15 VERIFIER ARM 7 — the § namedTfArgsFormalSlots4 / § namedMethodArgsWritten4
// boundary inside a COLLAPSED call, plus `this` as an argument (the corpus's own
// `create_item.set_item_context(this, l_sequencer);` shape) and a class-handle
// member chain.
package py15;
   typedef class pyc15;
   class hy15;
      int hp;
      function void two(int a, int b = 9); hp = a + b; endfunction
      function void obj(pyc15 o, int b); hp = b; endfunction
   endclass
   class pyc15;
      int cp15 = 1;
      hy15 hh15;
      function hy15 mky15(int f1, int f2);
         int loc15 = 2;
         mky15 = new();
         mky15.two(.a(f1), .b(f2));  // y10 fully NAMED association
         mky15.two(.b(f2), .a(f1));  // y11 NAMED, OUT OF ORDER
         mky15.two(f1, .b(loc15));   // y12 MIXED positional + named
         mky15.two(.a(loc15));       // y13 NAMED, defaulted formal omitted
         mky15.obj(this, f1);        // y14 `this` as an argument
         mky15.obj(null, loc15);     // y15 null as an argument
         mky15.two(hh15.hp, f2);     // y16 a class-handle MEMBER as argument
      endfunction
   endclass
endpackage

module my15;
   import py15::*;
   pyc15 c;
   initial begin c = new(); void'(c.mky15(1, 2)); end
endmodule
