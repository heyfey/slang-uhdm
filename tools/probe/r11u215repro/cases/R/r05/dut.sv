// § opIdxRecvElemFollowsPath215 — a method called without parentheses and a statement-position call (other arms: no firing)
package p;
  class fld;
    function int get_n_bits(); return 0; endfunction
    function void set(int v); endfunction
  endclass
  class reg_c;
    fld fields[$];
    function int f(int i);
      fields[i-1].set(1);
      return fields[i-1].get_n_bits;
    endfunction
  endclass
endpackage
module m;
endmodule
