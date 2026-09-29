// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — an enum member value of a typedef inside a function body
package p1;
  function automatic int f();
    typedef enum int {A = p2::K, B} le_t;
    le_t e;
    e = B;
    return int'(e);
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
