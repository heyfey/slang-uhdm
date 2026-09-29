// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — a function default argument
package p1;
  function automatic int f(int a = p2::K);
    return a;
  endfunction
  localparam int X = f();
endpackage
package p2;
  typedef enum logic [2:0] {E0, E1, E2, E3, E4} e_t;
  localparam int K = 4;
  localparam logic [7:0] W = 8'hA5;
endpackage
module dut (output int o);
  assign o = p1::X;
endmodule
