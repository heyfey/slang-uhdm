// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — an unpacked dimension of a function-local array
package p1;
  function automatic int f();
    int arr [p2::K];
    foreach (arr[i]) arr[i] = i;
    return arr[1];
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
