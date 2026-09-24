// v116 arm R -- statement positions never probed: $display argument, a plain
// assignment, a nested double call in one expression, inside fork/join_none,
// inside a for loop, and a with block naming a PACKAGE PARAMETER.
package pkg_r;
  parameter int PAR_R = 17;
endpackage
class mover_r;
  rand int m_one;
  rand int m_two;
  int m_cap;
  function void act();
    int i_r;
    $display("%0d", randomize(m_one));
    m_cap = randomize(m_one) + randomize(m_two);
    for (i_r = 0; i_r < 2; i_r = i_r + 1)
      if (!randomize(m_one) with { m_one < pkg_r::PAR_R; })
        m_cap = 1;
    if (!randomize(m_two) with { m_two > m_one; })
      m_cap = 2;
  endfunction
  task tk();
    fork
      if (!randomize(m_one) with { m_one > 0; })
        m_cap = 3;
    join_none
  endtask
endclass
module top_r;
  import pkg_r::*;
  mover_r r_one;
  initial begin
    r_one = new();
    r_one.act();
  end
endmodule
