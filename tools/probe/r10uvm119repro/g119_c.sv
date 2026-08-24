// arm C — THE FENCE: uvm116's landed cells (scope form, std::) must not move,
// and a dotted NON-randomize call with no constraint must not move either.
class txn_c;
  rand int unsigned c_one;
  rand int unsigned c_two;
  int unsigned c_lim;
  function int unsigned rd_c();
    return c_one;
  endfunction
  task body_c();
    // uvm116's LANDED scope form, both spellings
    if (!randomize(c_one) with { c_one > 4; c_one < 12; }) begin
      c_lim = 1;
    end
    if (!randomize(c_two)) begin
      c_lim = 2;
    end
  endtask
endclass

class user_c;
  // a USER function NAMED randomize — must never take the randomize arm
  int unsigned u_val;
  function int unsigned randomize_x();
    return u_val;
  endfunction
endclass

module top_c;
  int unsigned a_c, b_c;
  int st_c;
  txn_c t_c;
  user_c u_c;
  initial begin
    t_c = new();
    u_c = new();
    // std:: forms — a separate Surelog head (uvm116 residue R1), unchanged
    st_c = std::randomize(a_c, b_c);
    // a dotted NON-randomize call with no constraint at all
    b_c = t_c.rd_c();
    a_c = u_c.randomize_x();
  end
endmodule
