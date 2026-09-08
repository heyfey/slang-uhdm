// B2 — instantiated MODULE, export BELOW its definition, SEPARATED (slang
// resolves the export itself here, so the pristine binary already stamps it).
module v216_modb2;
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
endmodule
