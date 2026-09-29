// § opIdxRecvElemFollowsPath215 — plain reference indexes of a deep receiver in a class method and a module function (the elaborated view's face, opIdxRecvPlainElab215)
class fld;
  function int get_lsb_pos(); return 0; endfunction
endclass
package p;
  class fld2;
    function int get_lsb_pos(); return 0; endfunction
  endclass
  class reg_c;
    fld2 fields[$];
    function int f(int k);
      return fields[k].get_lsb_pos();
    endfunction
  endclass
endpackage
module m(input int k, output int o);
  fld fields[$];
  function automatic int f(int i);
    return fields[i].get_lsb_pos();
  endfunction
  always_comb o = fields[k].get_lsb_pos();
endmodule
