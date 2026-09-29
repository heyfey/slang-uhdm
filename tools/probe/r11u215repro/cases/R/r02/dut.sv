// § opIdxRecvElemFollowsPath215 — a module function and an always block reading a handle queue's method through an operation index
class fld;
  function int get_lsb_pos(); return 0; endfunction
endclass
module m(input int k, output int o);
  fld fields[$];
  function automatic int f(int i);
    return fields[i-1].get_lsb_pos() + fields[i + 1].get_lsb_pos();
  endfunction
  always_comb begin : blk
    o = fields[k*2].get_lsb_pos();
  end
endmodule
