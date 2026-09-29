// § memberInitReducedRootFolds228 § pkgPatFuncBodyLeftoverNoParent227 — the struct parameter reads the evaluated function's result member (Info = pk::C.u)
package pk;
  typedef struct packed { int x; int y; } info_t;
  typedef struct packed { info_t u; int z; } c_t;
  localparam info_t UU = '{x: 16, y: 2};
  function automatic c_t mk();
    c_t c; c.u = UU; c.z = 1; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module top(output logic [7:0] o);
  parameter pk::info_t Info = '{x: pk::C.u.x, y: 0};
  localparam int N = Info.x;
  logic [N-1:0] q;
  assign q = '1;
  assign o = 8'(q);
endmodule
