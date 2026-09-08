// vG — an interface declared INSIDE a module, with a separated export, and an
// outer module-level export of a different name.
module v216_mod_g;
  export "DPI-C" function eg_outer;
  function automatic int plain_g(int x);
    return x + 1;
  endfunction
  function automatic int eg_outer(int x);
    return x + 2;
  endfunction
  interface v216_if_g;
    export "DPI-C" function eg_inner;
    function automatic int plain_gi(int x);
      return x + 3;
    endfunction
    function automatic int eg_inner(int x);
      return x + 4;
    endfunction
  endinterface
endmodule
