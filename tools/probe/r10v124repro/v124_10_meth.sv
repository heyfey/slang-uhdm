// r10v124 arm 10 — METHODS on an indexed receiver, in STATEMENT position:
// push_back / push_front / pop_back / pop_front / delete() / delete(idx) /
// delete(key) / insert / a user function / a user TASK; and the same names in
// EXPRESSION position (size / num / exists / first) as the controls.
package Hive;
  typedef int Comb[$];
  typedef int Map[string];

  class Bee;
    int pollen;
    function void gather(int n); pollen += n; endfunction
    task fly(int n); pollen = n; endtask
  endclass

  class Colony;
    Comb Cells[string];
    Comb Rows[4];
    Map  Charts[3];
    Bee  Swarm[string];
    Bee  Flight[2];
    int  Depth;

    task tend(string kx, int ix);
      Cells[kx].push_back(1001);
      Cells[kx].push_front(1002);
      Rows[1].push_back(1003);
      void'(Rows[1].pop_back());
      void'(Cells[kx].pop_front());
      Rows[2].insert(0, 1004);
      Cells[kx].delete();
      Rows[3].delete(0);
      Charts[1].delete(kx);
      Charts[2].delete();
      Swarm[kx].gather(1005);
      Swarm[kx].fly(1006);
      Flight[0].gather(1007);
      Flight[1].fly(1008);
      Depth = Cells[kx].size();
      Depth = Charts[0].num();
      if (Charts[1].exists(kx)) Depth++;
      Depth = Rows[0].size();
    endtask
  endclass
endpackage

module Apiary;
  Hive::Colony cl;
  initial begin
    cl = new();
    cl.tend("nectar", 1);
  end
endmodule
