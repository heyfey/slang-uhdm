// vH — an interface that wildcard-imports a package (hoisted entries with no
// item index of their own) and carries its own separated export at item 0.
package v216_pkg_h;
  function automatic int p_one(int x);
    return x + 1;
  endfunction
  function automatic int p_two(int x);
    return x + 2;
  endfunction
endpackage
interface v216_if_h;
  import v216_pkg_h::*;
  export "DPI-C" function eh_one;
  function automatic int plain_h(int x);
    return p_one(x) + p_two(x);
  endfunction
  function automatic int eh_one(int x);
    return x + 3;
  endfunction
endinterface
