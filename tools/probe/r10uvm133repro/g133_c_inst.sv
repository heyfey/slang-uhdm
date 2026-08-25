// r10uvm133 arm C - the SAME $bits(<call>) reached through 1, 2 and 3
// instances, so the DEF listing and the ELAB listing both carry it.
// MEASUREMENT ONLY.  LHS is always golden (Surelog).
module leaf133_c #(parameter int PC = 4) (input logic clk, output int oc);
  int    cq[$];
  function automatic int cf133();
    return PC;
  endfunction
  always_comb begin
    oc = $bits(cf133()) + $bits(cq.size());
  end
endmodule

module mid133_c #(parameter int PM = 5) (input logic clk, output int om);
  int oa, ob;
  leaf133_c #(.PC(PM))     i_one (.clk(clk), .oc(oa));
  leaf133_c #(.PC(PM + 1)) i_two (.clk(clk), .oc(ob));
  assign om = oa + ob;
endmodule

module top133_c (input logic clk, output int ot);
  int t1, t2, t3;
  mid133_c #(.PM(5)) u_a (.clk(clk), .om(t1));
  mid133_c #(.PM(6)) u_b (.clk(clk), .om(t2));
  leaf133_c #(.PC(7)) u_c (.clk(clk), .oc(t3));
  assign ot = t1 + t2 + t3;
endmodule
