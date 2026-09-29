// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — part-select bounds, an indexed width and a replication count inside a function body
package p1;
  typedef struct packed { logic [2:0] x; logic [1:0][7:0] z; } s_t;
  function automatic int f();
    logic [7:0] v;
    s_t s;
    v = p2::W[p2::E3:0];
    v = p2::W[0 +: p2::E2];
    s = '{x: 1, z: '{p2::E2{8'h1}}};
    return int'(v) + int'(s);
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
