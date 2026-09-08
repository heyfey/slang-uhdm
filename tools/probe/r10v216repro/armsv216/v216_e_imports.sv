// vE — DPI IMPORTS (plain, context, pure) plus two separated exports written
// in reverse order.  The imports must not move and must keep their flags.
interface v216_if_e;
  import "DPI-C" function int ie_plain(int x);
  export "DPI-C" function ee_b;
  import "DPI-C" context function int ie_ctx(int x);
  export "DPI-C" function ee_a;
  import "DPI-C" pure function int ie_pure(int x);
  function automatic int ee_a(int x);
    return x + 1;
  endfunction
  function automatic int plain_e(int x);
    return x + 2;
  endfunction
  function automatic int ee_b(int x);
    return x + 3;
  endfunction
endinterface
