// § cloneRetParamFoldTsName236 — MiniAmiq #64390: a package parameter returned by a package function, read through an importing package
package p;
  parameter string rev = "1.2";
  parameter int num = 5;
  function string rev_string();
    return rev;
  endfunction
  function int get_num();
    return num;
  endfunction
endpackage
package q;
  import p::*;
  function string q_rev();
    return rev_string();
  endfunction
endpackage
module top (output int o);
  import q::*;
  initial begin
    string s;
    s = q_rev();
  end
  assign o = p::get_num();
endmodule
