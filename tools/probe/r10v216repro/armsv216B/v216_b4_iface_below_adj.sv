// B4 — interface, export BELOW its definition but ADJACENT (the v170_p_export
// `epsil7` shape).  Must be an identity permutation.
interface v216_ifb4;
  function automatic int plain_b(int x);
    return x + 1;
  endfunction
  function automatic int eb_one(int x);
    return x + 2;
  endfunction
  export "DPI-C" function eb_one;
  function automatic int plain_b2(int x);
    return x + 3;
  endfunction
endinterface
