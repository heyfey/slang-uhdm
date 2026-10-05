// § clsTdAssocIdxKwLoc251 (a $unit non-parameterized class typedef indexed by string, element string)
class c;
  typedef string tab_t [string];
  tab_t m;
  function tab_t get(); return m; endfunction
endclass
module top; c h; endmodule
