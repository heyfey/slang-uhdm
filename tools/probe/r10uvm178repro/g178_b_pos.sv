// r10uvm178 ARM B — THE REFERENCE POSITION DIMENSION.  MEASUREMENT ONLY.
// One parameter, read from FOUR positions inside a free package function:
//   xor-assign / if condition / call argument / return expression,
// plus a plain binary operand as the fifth control.  Each position appears
// BOTH in the parameter's home package AND in a wildcard-import clone of it,
// so the position and the listing can be separated.
// Names, numbers and declaration ORDER are varied on purpose: the positions are
// declared bottom-up in the clone and top-down at home.

package B_home178;
  parameter longint unsigned polyB178 = 64'h1_04c1_1db7;
  parameter int stepB178 = 9;

  function automatic longint unsigned b_xor178(input longint unsigned a);
    longint unsigned r;
    r = a;
    r ^= polyB178;                 // POS xor-assign
    return r;
  endfunction

  function automatic int b_cond178(input longint unsigned a);
    if (a == polyB178) return 1;   // POS if-condition
    else return 0;
  endfunction

  function automatic longint unsigned b_arg178(input longint unsigned a);
    return b_xor178(polyB178);     // POS call-argument
  endfunction

  function automatic longint unsigned b_ret178();
    return polyB178;               // POS return
  endfunction

  function automatic int b_bin178(input int a);
    return a + stepB178;           // POS binary operand (control)
  endfunction
endpackage

package B_clone178;
  import B_home178::*;

  function automatic longint unsigned c_xor178(input longint unsigned a);
    longint unsigned r;
    r = a;
    r ^= polyB178;
    return r;
  endfunction

  function automatic int c_bin178(input int a);
    return a + stepB178;
  endfunction

  function automatic longint unsigned c_ret178();
    return polyB178;
  endfunction

  function automatic longint unsigned c_arg178(input longint unsigned a);
    return c_xor178(polyB178);
  endfunction

  function automatic int c_cond178(input longint unsigned a);
    if (a == polyB178) return 1;
    else return 0;
  endfunction
endpackage

module m178b (input logic clk, output longint unsigned y1, y2, y3, output int y4, y5);
  import B_home178::*;
  import B_clone178::*;
  assign y1 = b_xor178(64'd7);
  assign y2 = b_ret178();
  assign y3 = c_xor178(64'd8);
  assign y4 = b_cond178(64'd9) + b_bin178(3);
  assign y5 = c_cond178(64'd10) + c_bin178(4);
endmodule
