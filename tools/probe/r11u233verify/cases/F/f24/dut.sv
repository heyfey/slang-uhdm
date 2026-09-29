// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — a typedef of a packed vector inside a function body, and a cast to it
package p1;
  function automatic int f(int x);
    typedef logic [p2::K-1:0] v_t;
    v_t v;
    v = v_t'(x);
    return int'(v);
  endfunction
  localparam int X = f(9);
endpackage
package p2;
  typedef enum logic [2:0] {E0, E1, E2, E3, E4} e_t;
  localparam int K = 4;
  localparam logic [7:0] W = 8'hA5;
endpackage
module dut (output int o);
  assign o = p1::X;
endmodule
