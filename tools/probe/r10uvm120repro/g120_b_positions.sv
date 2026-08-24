// r10uvm120 arm b: the POSITION face — where inside a package-function return
// expression golden substitutes a bare parameter read, and where it does not.
package p120b;
  parameter int    K = 5;
  parameter string S = "abc";
  localparam int   ARR [0:7] = '{1, 2, 3, 4, 5, 6, 7, 8};

  function int helper(int a);      return a;            endfunction
  function int f_bare();           return K;            endfunction
  function int f_opl();            return K + 1;        endfunction
  function int f_opr();            return 1 + K;        endfunction
  function int f_paren();          return (K);          endfunction
  function int f_deep();           return ((K + 1) * 2); endfunction
  function int f_terncond();       return K ? 1 : 0;    endfunction
  function int f_ternarm();        return 1 ? K : 0;    endfunction
  function int f_cmp();            return (K == 5);     endfunction
  function int f_cat();            return {K, K};       endfunction
  function int f_idx();            return ARR[K];       endfunction
  function int f_call();           return helper(K);    endfunction
  function int f_calldeep();       return helper(K + 1); endfunction
  function int f_sysarg();         return $countones(K); endfunction
  function string f_sysfmt();      return $sformatf("%0d", K); endfunction
  function string f_scat();        return {S, "x"};     endfunction
  function int f_unary();          return -K;           endfunction

  function int f_notret();  int t; t = K; return t;     endfunction
  function int f_ifret();   if (K > 0) return K; else return 0; endfunction
  function int f_begret();  begin return K; end         endfunction
  function int f_forret();  for (int i = 0; i < 1; i++) return K; endfunction
  function int f_two();     int t; t = 1; return K;     endfunction
endpackage

module top120b;
  initial $display(p120b::f_bare(), p120b::f_opl(), p120b::f_notret());
endmodule
