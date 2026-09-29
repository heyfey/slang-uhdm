// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — loop bounds, repeat and while conditions in a function body
package p1;
  function automatic int f();
    int s = 0;
    for (int i = 0; i < p2::K; i++) s++;
    repeat (p2::K) s++;
    while (s < p2::K * 4) s++;
    return s;
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
