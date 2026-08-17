// ARG-KIND matrix A: constants, operations, selects, casts, nesting.
package kp5a;
  typedef logic [7:0] b_t;
  import "DPI-C" context function int dpi5(input int a);
  function int f1 (int a);                  return dpi5(a); endfunction
  function int f3 (int a, b_t b, string c); return dpi5(a) + int'(b) + c.len(); endfunction
  function int fbit (logic l);              return dpi5(int'(l)); endfunction
  function int k_const ();       return f1(3); endfunction
  function int k_strlit ();      return f3(1, 8'h2, "lit"); endfunction
  function int k_op (int a);     return f1(a + 1); endfunction
  function int k_concat (b_t a); return f3(1, {a[3:0], a[7:4]}, "x"); endfunction
  function int k_tern (int a);   return f1(a ? 1 : 2); endfunction
  function int k_bitsel (b_t a); return fbit(a[0]); endfunction
  function int k_partsel (b_t a); return f3(1, {4'b0, a[3:0]}, "x"); endfunction
  function int k_pos3 (int a, b_t b, string c); return f3(a, b, c); endfunction
  function int k_nested (int a); return f1(f1(a)); endfunction
  function int k_cast (b_t a);   return f1(int'(a)); endfunction
  function int k_twocalls (int a, int b); return f1(a) + f1(b); endfunction
endpackage
module m5a;
  int r[12]; kp5a::b_t bb;
  initial begin
    r[0]=kp5a::k_const(); r[1]=kp5a::k_strlit(); r[2]=kp5a::k_op(1);
    r[3]=kp5a::k_concat(bb); r[4]=kp5a::k_tern(1); r[5]=kp5a::k_bitsel(bb);
    r[6]=kp5a::k_partsel(bb); r[7]=kp5a::k_pos3(1,bb,"s");
    r[11]=kp5a::k_twocalls(1,2);
  end
endmodule
