// B1 — interface (never instantiated), export BELOW its definition, SEPARATED.
interface v216_ifb1;
  function automatic int eb_one(int x);
    return x + 1;
  endfunction
  function automatic int plain_b(int x);
    return x + 2;
  endfunction
  export "DPI-C" function eb_one;
  function automatic int plain_b2(int x);
    return x + 3;
  endfunction
endinterface
