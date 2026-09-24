// v119 arm L — the ONE-CHARACTER and PATHOLOGICAL name shapes, plus a member
// literally named like the method and a receiver whose class also declares a
// user method named randomize_x.
class r;
  rand int unsigned x;
  rand int unsigned randomize_x;
  function int unsigned randomize_y();
    return 2;
  endfunction
endclass

class R;
  rand int unsigned x;
endclass

class drv_l;
  r a;
  R A;
  r m_a_very_long_member_name_that_goes_on_l;
  int unsigned o;
  task t();
    // one-character receiver, one-character member
    if (!a.randomize() with { x > 1; }) o = 1;
    // a receiver differing from the one above only by CASE
    if (!A.randomize() with { x > 2; }) o = 2;
    // a very long receiver name
    if (!m_a_very_long_member_name_that_goes_on_l.randomize() with { x > 3; }) o = 3;
    // the with-block constrains a member whose NAME contains "randomize"
    if (!a.randomize() with { randomize_x > 4; }) o = 4;
    // an identifier list naming that member
    if (!a.randomize(randomize_x) with { randomize_x < 8; }) o = 5;
    // a USER method whose name starts with randomize, beside
    o = a.randomize_y();
  endtask
endclass

module top_l;
  drv_l d;
  initial begin
    d = new();
    d.t();
  end
endmodule
