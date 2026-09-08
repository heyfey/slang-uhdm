// v214 arm 14 — REFERENT KINDS THE GRID DOES NOT SPELL: a `type` parameter, a
// real parameter, a string parameter used in a string context, a signed typed
// parameter, a parameter whose Rhs is a ternary, and a parameter whose Rhs is a
// system function call — all read from a def clone body.
package pv14;
  parameter type T14 = int;
  parameter real ya14 = 1.5;
  parameter yb14 = ya14;
  parameter string ys14 = "abc";
  parameter yt14 = ys14;
  parameter signed [7:0] yg14 = -3;
  parameter yh14 = yg14;
  parameter yi14 = (yg14 > 0) ? 1 : 2;
  parameter yj14 = $clog2(64);
  parameter yk14 = yj14;
  function automatic int ysink14(int a); return a; endfunction
  class Y14;
    extern function int y_rd14();
    extern function string y_str14();
    extern function real y_real14();
  endclass
  function int Y14::y_rd14();
    T14 t = 0;
    return ysink14(int'(yh14) + yi14 + yk14 + int'(t));
  endfunction
  function string Y14::y_str14();
    return yt14;
  endfunction
  function real Y14::y_real14();
    return yb14;
  endfunction
endpackage
module topv14;
  pv14::Y14 y = new();
  int x;
  initial x = y.y_rd14();
endmodule
