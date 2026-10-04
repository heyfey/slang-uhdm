// § cloneRetParamFoldTsName236 — a returned operation of a parameter
package p;
  parameter string rev = "1.2";
  parameter int num = 5;
  localparam int lp = 7;
  function string rev_string();
    return rev;
  endfunction
  function int get_num(int s);
    return num + 1;
  endfunction
endpackage
package q;
  import p::*;
  function string q_rev();
    return rev_string();
  endfunction
  function int q_num();
    return get_num(1);
  endfunction
endpackage
module top (output int o);
  import q::*;
  initial begin
    string s;
    s = q_rev();
  end
  assign o = q_num();
endmodule
