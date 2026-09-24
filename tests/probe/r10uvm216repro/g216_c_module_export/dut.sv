// r10uvm216 ARM C — THE MODULE CONTROL.  The same separated-export shape in a
// MODULE (both a TOP module and a NESTED instance of another module), so the
// law's holder conjunct is measured: does the position/field rule belong to
// interfaces only, or to every `instance`?
module c216_sub();
   import "DPI-C" context function void c216_imp(input int x);

   export "DPI-C" function c216_second;
   export "DPI-C" function c216_first;

   int c216_state;

   function void c216_plain1(int p);
      c216_state = p;
   endfunction

   function int c216_plain2(int p);
      return p + 1;
   endfunction

   function void c216_first(input int a, input string b);
      c216_state = a;
      c216_imp(a);
   endfunction

   function int c216_second(input int a);
      return a + c216_state;
   endfunction

   function void c216_plain4();
      c216_state = 0;
   endfunction
endmodule

module c216_top();
   export "DPI-C" function c216_top_second;
   export "DPI-C" function c216_top_first;

   int c216_top_state;

   function void c216_top_plain1(int p);
      c216_top_state = p;
   endfunction

   function void c216_top_first(input int a);
      c216_top_state = a;
   endfunction

   function int c216_top_second(input int a);
      return a + c216_top_state;
   endfunction

   c216_sub u_sub();
endmodule
