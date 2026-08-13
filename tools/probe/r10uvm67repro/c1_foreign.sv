package v3other;
  parameter V3O_W = 100*8-1;
  parameter V3O_LIT = 799;
endpackage
package v3pkg;
  import v3other::*;
  parameter V3P_W = 120*8-1;
  function bit[V3O_W:0] v3_foreign_bits(string s);
    v3_foreign_bits = 0;
  endfunction
  function bit[v3other::V3O_LIT:0] v3_qual_bits(string s);
    v3_qual_bits = 0;
  endfunction
  function bit[V3P_W:0] v3_own_bits(string s);
    v3_own_bits = 0;
  endfunction
endpackage
