// § cloneRetParamFoldTsName236 — package parameters returned by package functions, read through an importing package: string, int, operation, conditional return, two importers
package p;
  parameter string rev = "1.2";
  parameter int num = 5;
  localparam int lp = 7;
  function string rev_string();
    return rev;
  endfunction
  function int get_num(int s);
    if (s > 0) return num;
    else return lp;
  endfunction
  function int get_sum();
    return num + 1;
  endfunction
endpackage
package q;
  import p::*;
  function string q_rev();
    return rev_string();
  endfunction
  function int q_num();
    return get_num(1) + get_sum();
  endfunction
endpackage
package r;
  import p::rev_string;
  import p::get_num;
  function string r_rev();
    return rev_string();
  endfunction
  function int r_num();
    return get_num(0);
  endfunction
endpackage
module top (output int o, output int o2);
  import q::*;
  string s;
  initial begin
    s = q_rev();
    s = r::r_rev();
  end
  assign o = q_num();
  assign o2 = r::r_num();
endmodule
