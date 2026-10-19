// § tdAtomRetAliasTwin412
module top;
  typedef int T;
  function T mf(); return 1; endfunction
  class K;
    typedef int U;
    function U kf(); return 2; endfunction
    extern function U kg();
  endclass
  function K::U K::kg(); return 3; endfunction
endmodule
