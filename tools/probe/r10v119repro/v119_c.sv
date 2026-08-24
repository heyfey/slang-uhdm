// v119 arm C — CONTAINER-ELEMENT and CHAINED receivers
class it_c;
  rand int unsigned c_x;
  rand int unsigned c_y;
endclass

class hold_c;
  it_c mid_c;
endclass

class drv_c;
  it_c q_c[$];
  it_c aa_c[string];
  it_c dyn_c[];
  it_c fix_c[3];
  hold_c hh_c;
  it_c plain_c;
  int unsigned out_c;
  task run_c();
    // a QUEUE element receiver
    if (!q_c[0].randomize() with { c_x > 1; }) out_c = 1;
    // an ASSOCIATIVE element receiver, string key
    if (!aa_c["kk"].randomize() with { c_x > 2; }) out_c = 2;
    // a DYNAMIC array element receiver
    if (!dyn_c[1].randomize() with { c_y > 3; }) out_c = 3;
    // a FIXED array element with a NON-literal index
    if (!fix_c[out_c].randomize() with { c_y > 4; }) out_c = 4;
    // this.-rooted CHAIN
    if (!this.hh_c.mid_c.randomize() with { c_x > 5; }) out_c = 5;
    // a plain member with an identifier list AND a with block
    if (!this.plain_c.randomize(c_x) with { c_x > 6; }) out_c = 6;
  endtask
endclass

module top_c;
  drv_c d_c;
  initial begin
    d_c = new();
    d_c.run_c();
  end
endmodule
