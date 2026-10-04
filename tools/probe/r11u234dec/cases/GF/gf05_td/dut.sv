// § retNameLocalClassTsAtType234: the return written with a package typedef of the class (typedef rgn h_t)
package p;
  class rgn; endclass
  typedef rgn h_t;
  function h_t mk(int n);
    mk = null;
  endfunction
endpackage
