interface v3if;
  parameter V3I_W = 30*8-1;
  function bit[V3I_W:0] v3if_bits(string s);
    v3if_bits = 0;
  endfunction
endinterface
