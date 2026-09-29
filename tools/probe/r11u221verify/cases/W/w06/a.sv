// § tfArgOutsideClassKeyOrder216v + § tfArgImportCloneFollows216 — first file of w06: the typedef's package
package p;
  typedef enum logic [1:0] {A0, B0, C0} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
