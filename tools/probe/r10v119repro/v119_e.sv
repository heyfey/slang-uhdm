// v119 arm E — HOMES and EXPRESSION POSITIONS
package pk_e;
  class it_e;
    rand int unsigned e_v;
  endclass
  // a PACKAGE-level function home
  function automatic int unsigned pk_go_e(it_e h_e);
    if (!h_e.randomize() with { e_v > 1; }) return 1;
    return 0;
  endfunction
endpackage

class drv_e;
  pk_e::it_e r_e;
  int unsigned out_e;
  bit ok_e;
  // an OUT-OF-BODY (extern) task home
  extern task oob_e();
  // an IN-BODY function home, with the call as the RETURN expression
  function bit ret_e();
    return r_e.randomize() with { e_v > 2; };
  endfunction
endclass

task drv_e::oob_e();
  int unsigned loc_e;
  loc_e = 3;
  // assignment RVALUE
  ok_e = r_e.randomize() with { e_v > loc_e; };
  // a direct if-condition, no !
  if (r_e.randomize() with { e_v > 4; }) out_e = 1;
  // under !
  if (!r_e.randomize() with { e_v > 5; }) out_e = 2;
  // a while condition
  while (r_e.randomize() with { e_v > 6; }) out_e = 3;
  // a ternary operand
  out_e = (r_e.randomize() with { e_v > 7; }) ? 8 : 9;
  // a binary operand
  ok_e = (r_e.randomize() with { e_v > 8; }) && (out_e > 0);
  // a $display argument
  $display("%0d", r_e.randomize() with { e_v > 9; });
  // inside a for loop body
  for (int i = 0; i < 2; i++)
    if (!r_e.randomize() with { e_v > 10; }) out_e = 4;
endtask

module top_e2;
  drv_e d_e;
  pk_e::it_e m_e;
  int unsigned m_out_e;
  initial begin
    d_e = new();
    m_e = new();
    d_e.oob_e();
    // a MODULE initial home
    if (!m_e.randomize() with { e_v > 11; }) m_out_e = 1;
    m_out_e = pk_e::pk_go_e(m_e);
  end
endmodule
