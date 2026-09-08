// B5 — one export ABOVE (separated) and one BELOW (separated) in the same
// never-instantiated interface.
interface v216_ifb5;
  export "DPI-C" function up_one;
  function automatic int plain_p(int x);
    return x + 1;
  endfunction
  function automatic int down_one(int x);
    return x + 2;
  endfunction
  function automatic int plain_q(int x);
    return x + 3;
  endfunction
  export "DPI-C" function down_one;
  function automatic int up_one(int x);
    return x + 4;
  endfunction
endinterface
