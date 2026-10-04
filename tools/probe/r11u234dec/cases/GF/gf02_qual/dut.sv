// § retNameLocalClassTsAtType234: a package function returning a class of another package, written q::rgn
package q;
  class rgn; endclass
endpackage
package p;
  function q::rgn mk(int n);
    mk = null;
    if (n == 0) return mk;
  endfunction
endpackage
