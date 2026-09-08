// vB — R2 shape: the export is written BELOW its definition.  Golden is
// reported to emit TWO entries; we emit one.  This arm must not get WORSE.
interface v216_if_b;
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
