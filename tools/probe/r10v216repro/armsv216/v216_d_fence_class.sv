// vD — FENCE 1: a class method whose bare name equals a module-level export's
// name must never be matched by the module's export item.
module v216_mod_d;
  export "DPI-C" function get;
  function automatic int plain_d(int x);
    return x + 1;
  endfunction
  class v216_cls_d;
    function automatic int get(int x);
      return x + 2;
    endfunction
  endclass
  function automatic int get(int x);
    return x + 3;
  endfunction
endmodule
