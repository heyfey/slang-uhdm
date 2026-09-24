// r10v218 arm b3 — NESTING and the VIRTUAL-INTERFACE corpus shape.  The
// interface is never instantiated but IS held by a class as a virtual
// interface, which is how the corpus row (`svaunit_vpi_interface`) reaches it.
interface if3v;
   bit mv3v;
   int mint3v;
   function int f3v(int a_a, int a_b);
      int l3v;
      int arr3v[4];
      // nested call arguments, three deep
      c3v(g3v(a_a));                       // n01 formal under a NESTED call
      c3v(g3v(g3v(l3v)));                  // n02 local, two calls deep
      c3v(arr3v[a_a]);                     // n03 select INDEX in a call arg
      c3v(arr3v[l3v] + a_b);               // n04 index + formal, operation
      if (g3v(a_a) == 1) mv3v = 1'b1;      // n05 call in a CONDITION
      if (arr3v[a_b] == 1) mv3v = 1'b1;    // n06 select index in a cond
      if (mint3v == 1) mv3v = 1'b1;        // n07 iface MEMBER, cond (bare)
      c3v(mint3v);                         // n08 iface MEMBER, call arg (bare)
      c3v(mint3v + a_a);                   // n09 member AND formal together
      if (a_a == 1 && l3v == 2) mv3v = 1'b1; // n10 two refs, one cond
      return l3v;
   endfunction
   function void c3v(int z); endfunction
   function int  g3v(int z); return z; endfunction
endinterface

class holder3v;
   virtual if3v vif3v;                     // the corpus shape: VIRTUAL only
   function void use3v(int a_u);
      if (a_u == 1) vif3v.mv3v = 1'b1;
   endfunction
endclass

module top3v;
   holder3v h;
   initial begin end
endmodule
