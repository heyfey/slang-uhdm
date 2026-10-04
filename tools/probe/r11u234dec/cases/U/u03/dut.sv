// § decode U: u01 with a class-handle class-scope typedef (no dimension)
package p;
  class rsrc; endclass
  class types;
    typedef rsrc h_t;
  endclass
  class pool;
    function void f(types::h_t h);
    endfunction
  endclass
endpackage
