// r10uvm124 arm C — the HOME axis: the same indexed-receiver statement call in
// an in-body class method, an OUT-OF-BODY class method, a free package
// function, a free package task, a module task, a module initial block and a
// module always block.  Homes are written in a deliberately scrambled order.
package Homes124;
  class Trunk;
    int Leafs[$];
  endclass
  class Branch;
    Trunk Twig[$];
    Trunk Named[string];
    function automatic void Inside(int Jx);
      Twig[Jx].Leafs.push_back(201);
    endfunction
    extern task Outside(string Sy);
    extern function void Faraway(int Ky);
  endclass
  task Branch::Outside(string Sy);
    Named[Sy].Leafs.push_back(202);
  endtask
  function void Branch::Faraway(int Ky);
    Twig[Ky].Leafs.push_back(203);
  endfunction
  function automatic void FreeFn(ref Trunk Grove[$], int Lx);
    Grove[Lx].Leafs.push_back(204);
  endfunction
  task automatic FreeTk(ref Trunk Copse[string], string Mx);
    Copse[Mx].Leafs.push_back(205);
  endtask
endpackage
module HomesTop124;
  import Homes124::*;
  Trunk Stand[$];
  Trunk Named2[string];
  task automatic ModTask(int Nx);
    Stand[Nx].Leafs.push_back(206);
  endtask
  initial begin
    Stand[0].Leafs.push_back(207);
  end
  always @(*) begin
    Named2["k"].Leafs.push_back(208);
  end
endmodule
