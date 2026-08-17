// ORDER MATRIX for § pkgRetTopCallArgFormalTs8.  Every callee is unfoldable
// (its body reaches a DPI import), so "the fold" is never the fence here and
// the only variable is WHERE THE CALLEE IS DECLARED relative to the caller.
package op4;
  typedef logic [7:0] b_t;
  import "DPI-C" context function int dpi4(input int a);
  // ---- o1 CONTROL: callee declared BEFORE the caller
  function b_t early_cal (b_t x, b_t y);
    return b_t'(dpi4(int'(x)) + y);
  endfunction
  function b_t o1 (b_t a, b_t b);
    return early_cal(a, b);
  endfunction
  // ---- o3 SELF RECURSION (callee == caller)
  function b_t o3 (b_t a, b_t b);
    if (a == 0) return b_t'(dpi4(int'(b)));
    return o3(b_t'(a-1), b);
  endfunction
  // ---- o4 MUTUAL RECURSION: o4f is declared FIRST, o4g SECOND
  function b_t o4f (b_t a, b_t b);
    return o4g(a, b);          // FORWARD (o4g not yet declared)
  endfunction
  function b_t o4g (b_t a, b_t b);
    return o4f2(a, b);         // o4f2 declared after -> forward too
  endfunction
  function b_t o4f2 (b_t a, b_t b);
    return b_t'(dpi4(int'(a)) + b);
  endfunction
  function b_t o4h (b_t a, b_t b);
    return o4g(a, b);          // BACKWARD (o4g already declared)
  endfunction
  // ---- o2 the plain FORWARD case
  function b_t o2 (b_t a, b_t b);
    return late_cal(a, b);
  endfunction
  function b_t late_cal (b_t x, b_t y);
    return b_t'(dpi4(int'(x)) + y);
  endfunction
endpackage
module m4;
  op4::b_t z1,z2,z3,z4,z5,z6;
  initial begin
    z1 = op4::o1(8'h1,8'h2); z2 = op4::o2(8'h1,8'h2); z3 = op4::o3(8'h4,8'h2);
    z4 = op4::o4f(8'h1,8'h2); z5 = op4::o4g(8'h1,8'h2); z6 = op4::o4h(8'h1,8'h2);
  end
endmodule
