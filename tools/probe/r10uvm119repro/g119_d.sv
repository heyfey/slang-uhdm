// arm D — receiver surfaces: this., chained h.q., and an argument list
class inner_d;
  rand int unsigned d_alpha;
  rand int unsigned d_beta;
endclass

class holder_d;
  inner_d q_d;
endclass

class outer_d;
  rand int unsigned d_self;
  holder_d h_d;
  inner_d p_d;
  int unsigned res_d;
  task run_d();
    // the receiver IS the handle
    if (!this.randomize() with { d_self < 9; }) begin
      res_d = 1;
    end
    // a CHAINED receiver
    if (!h_d.q_d.randomize() with { d_alpha > 2; }) begin
      res_d = 2;
    end
    // a member randomize carrying an identifier list AND a with-block
    if (!p_d.randomize(d_alpha) with { d_alpha < 40; }) begin
      res_d = 3;
    end
    // two names in the identifier list
    if (!p_d.randomize(d_alpha, d_beta) with { d_beta > 1; }) begin
      res_d = 4;
    end
    // randomize(null) with a with-block
    if (!p_d.randomize(null) with { d_alpha != 7; }) begin
      res_d = 5;
    end
  endtask
endclass

module top_d;
  outer_d o_d;
  initial begin
    o_d = new();
    o_d.run_d();
  end
endmodule
