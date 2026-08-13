package v3pkg;
  parameter V3P_W = 120*8-1;
  typedef bit [V3P_W:0] v3_bits_t;
  function v3_bits_t v3_td_bits(string s);
    v3_td_bits = 0;
  endfunction
endpackage
