// § opIdxRecvElemFollowsPath215 — two-level receivers: the index on the first and on the second segment
package p;
  class fld;
    function int get_lsb_pos(); return 0; endfunction
  endclass
  class blk_c;
    fld fields[$];
  endclass
  class reg_c;
    blk_c blks[$];
    blk_c one;
    function int f(int i);
      return one.fields[i-1].get_lsb_pos();
    endfunction
  endclass
endpackage
module m;
endmodule
