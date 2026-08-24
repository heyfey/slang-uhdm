// v119 arm A2 - arm A with the surelog-rejected super cells removed
class base_a2;
  rand int unsigned a2_lo;
  rand int unsigned a2_hi;
endclass

class deriv_a2 extends base_a2;
  rand int unsigned a2_mid;
  int unsigned out_a2;
  task run_a2();
    // super receiver, WITH a constraint block
    // super receiver, NO constraint block (the fence twin)
    // this receiver in the SAME scope, both spellings
    if (!this.randomize() with { a2_mid > 3; }) out_a2 = 3;
    if (!this.randomize()) out_a2 = 4;
  endtask
endclass

module top_a2;
  deriv_a2 d_a2;
  initial begin
    d_a2 = new();
    d_a2.run_a2();
  end
endmodule
