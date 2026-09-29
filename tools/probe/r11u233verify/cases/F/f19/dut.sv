// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — a size cast by the forward parameter in a function body
package p1;
  function automatic int f(int x);
    return int'(p2::K'(x));
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
