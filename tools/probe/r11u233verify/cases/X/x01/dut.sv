// § memberInitReducedRootFolds228 § pkgPatFuncBodyLeftoverNoParent227 — a struct parameter whose root is a package pattern read whole by an evaluated function
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
  parameter pk::info_t Info = pk::UU;
  localparam int N = Info.x;
  logic [N-1:0] q;
  assign q = '1;
  assign o = 8'(q);
endmodule
