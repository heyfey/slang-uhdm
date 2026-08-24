// arm H — THE BOUNDARY SURFACES: spellings the corpus never writes but the
// predicate must answer for, plus a MODULE-scope receiver and a longer
// identifier list.
class it_h;
  rand int unsigned h_a;
  rand int unsigned h_b;
  rand int unsigned h_c;
endclass

class hold_h;
  it_h deep_h;
endclass

class drv_h;
  it_h r_h;
  it_h arr_h[4];
  hold_h hh_h;
  int unsigned out_h;
  task run_h();
    // parens-LESS member randomize with a constraint block (IEEE A.2.10 makes
    // the argument list optional)
    if (!r_h.randomize with { h_a > 1; }) out_h = 1;
    // an INDEXED receiver
    if (!arr_h[1].randomize() with { h_a > 2; }) out_h = 2;
    // a SPACED spelling — the anchor must refuse and keep the pristine shape
    if (!r_h . randomize() with { h_a > 3; }) out_h = 3;
    // a CHAINED receiver carrying an identifier list
    if (!hh_h.deep_h.randomize(h_a) with { h_a > 4; }) out_h = 4;
    // THREE names in the identifier list
    if (!r_h.randomize(h_a, h_b, h_c) with { h_c > 5; }) out_h = 5;
    // the identifier list WITHOUT a with-block, three names (the fence)
    if (!r_h.randomize(h_a, h_b, h_c)) out_h = 6;
  endtask
endclass

module top_h;
  it_h mod_h;          // a MODULE-scope receiver
  int unsigned m_out;
  drv_h dh;
  initial begin
    mod_h = new();
    dh = new();
    if (!mod_h.randomize() with { h_a > 7; }) m_out = 1;
    if (!mod_h.randomize(h_b) with { h_b > 8; }) m_out = 2;
    dh.run_h();
  end
endmodule
