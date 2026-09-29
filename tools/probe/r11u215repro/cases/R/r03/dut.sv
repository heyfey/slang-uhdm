// § opIdxRecvElemFollowsPath215 — nested operations, a call and a built-in size() inside the index (MiniAmiq's sva_details[sva_details.size() - 1] shape), a parameter operand
package p;
  class fld;
    function int get_lsb_pos(); return 0; endfunction
  endclass
  function automatic int g(int x); return x; endfunction
  class reg_c;
    localparam int N = 4;
    fld fields[$];
    function int f(int i, int j);
      int a;
      a = fields[i*2+j].get_lsb_pos();
      a = fields[g(i)-1].get_lsb_pos();
      a = fields[fields.size()-1].get_lsb_pos();
      a = fields[N-1].get_lsb_pos();
      a = fields[j-i].get_lsb_pos();
      return a;
    endfunction
  endclass
endpackage
module m;
endmodule
