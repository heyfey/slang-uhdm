// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — a class inside the later package, and a class of the earlier package reading it
package p1;
  typedef struct packed { logic [2:0] x; } s_t;
  localparam s_t S = '{x: p2::E1};
  class A;
    function int g(); return p2::K; endfunction
  endclass
  localparam int X = int'(S);
endpackage
package p2;
  typedef enum logic [2:0] {E0, E1, E2, E3, E4} e_t;
  localparam int K = 4;
  localparam logic [7:0] W = 8'hA5;
  class C; static int K = 3; endclass
endpackage
module dut (output int o);
  assign o = p1::X;
endmodule
