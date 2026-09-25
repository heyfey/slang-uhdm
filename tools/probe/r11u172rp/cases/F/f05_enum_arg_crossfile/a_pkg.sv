package pa;
  typedef enum logic [1:0] { A, B, C } e_t;
  function automatic logic g(e_t v);
    return v == A;
  endfunction
endpackage
