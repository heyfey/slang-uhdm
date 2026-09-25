package pa;
  typedef struct packed { logic [1:0] x; logic y; } s_t;
  function automatic logic f(s_t v);
    return v.y;
  endfunction
endpackage
