// r10uvm126 grid D - SHARING and INSTANCE COUNT.  The same class is
// parameterised and instantiated ONE, TWO and THREE times so the question
// "one element typespec per SITE or per INSTANCE?" is asked directly, and the
// same keyword local is repeated in three sibling methods of one class so the
// "per declaration" half is asked too.  Written in a MODULE (not a package) so
// the vpiInstance half differs from grids A-C.
module m_delta126;

  class Rep126 #(int WIDE126 = 1);
    task once();
      string  r1s126 [2];
      real    r1r126 [3];
      time    r1t126 [4];
      r1s126[1] = "x"; r1r126[2] = 1.25; r1t126[3] = 5;
    endtask
    task twice();
      string  r2s126 [3];
      shortint r2i126 [2];
      r2s126[2] = "y"; r2i126[1] = 16'd3;
    endtask
    function int thrice();
      string  r3s126 [4];
      longint r3l126 [2];
      r3s126[3] = "z"; r3l126[1] = 64'd7;
      return WIDE126;
    endfunction
  endclass

  Rep126 #(1) one126;
  Rep126 #(2) two126;
  Rep126 #(3) three126;

  // A plain module task with the same keyword locals, DIFFERENT sizes.
  task modOnce126();
    string   ms126 [5];
    integer  mi126 [6];
    shortreal mf126 [7];
    ms126[4] = "q"; mi126[5] = 9; mf126[6] = 2.5;
  endtask

  initial begin
    one126 = new(); two126 = new(); three126 = new();
    one126.once(); two126.twice(); void'(three126.thrice());
    modOnce126();
  end
endmodule
