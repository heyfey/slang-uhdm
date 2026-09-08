// vA — the law, reduced: a never-instantiated interface whose two exports sit
// far above their definitions and in the OPPOSITE order, with a plain
// function and a DPI import between.
interface v216_if_a;
  export "DPI-C" function ea_two;
  export "DPI-C" function ea_one;
  function automatic int plain_mid(int x);
    return x + 1;
  endfunction
  import "DPI-C" function int imp_mid(int x);
  function automatic int ea_one(int x);
    return x + 2;
  endfunction
  function automatic int plain_late(int x);
    return x + 3;
  endfunction
  function automatic int ea_two(int x);
    return x + 4;
  endfunction
endinterface
