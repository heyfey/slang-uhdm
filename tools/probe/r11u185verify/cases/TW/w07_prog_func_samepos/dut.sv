// § tdKeyKeepsUnresolved176v
program pr(input pa::s_t i);
  import pa::*;
  function automatic logic g(s_t v);
    return v.x[0];
  endfunction
  initial $display(g(i), pb::f(i));
endprogram
