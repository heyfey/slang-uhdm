// v119 arm A — super.randomize() with {…}, ISOLATED (a shape no g119 arm writes)
class base_a;
  rand int unsigned a_lo;
  rand int unsigned a_hi;
endclass

class deriv_a extends base_a;
  rand int unsigned a_mid;
  int unsigned out_a;
  task run_a();
    // super receiver, WITH a constraint block
    if (!super.randomize() with { a_lo < 5; }) out_a = 1;
    // super receiver, NO constraint block (the fence twin)
    if (!super.randomize()) out_a = 2;
    // this receiver in the SAME scope, both spellings
    if (!this.randomize() with { a_mid > 3; }) out_a = 3;
    if (!this.randomize()) out_a = 4;
  endtask
endclass

module top_a;
  deriv_a d_a;
  initial begin
    d_a = new();
    d_a.run_a();
  end
endmodule
