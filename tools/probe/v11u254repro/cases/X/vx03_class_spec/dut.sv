// § procReplCountOwner254 (a replication count and a two-level package select as class specialization parameters, and in a class method body)
package cp;
  parameter logic [1:0][3:0][7:0] R3 = '1;
  parameter int N = 2;
endpackage
class c #(parameter logic [3:0] P = 0);
  function logic [3:0] get(); return P; endfunction
endclass
module top import cp::*; #(parameter int W = 1) (output logic [3:0] o, output logic [7:0] p);
  c #({N{2'b10}}) h;
  c #(4'(cp::R3[W][W-1])) h2;
  initial begin : ib
    h = new; h2 = new;
    o = h.get() ^ h2.get();
    p = cp::R3[W][W-1];
  end
endmodule
