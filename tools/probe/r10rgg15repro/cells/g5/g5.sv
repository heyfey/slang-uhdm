// r10rgg15 grid g5 — THE DECIDING AXIS: a formal WITH a written default vs a
// formal WITHOUT one, each overridden by every unsized fill, at widths that are
// NOT 64 (so a flat-64 mint cannot accidentally agree).  The no-default half is
// the u2r `unbased_unsized_param` fence reproduced at other widths.
// MEASUREMENT ONLY.
module g5_wd #(                       // WITH default
  parameter bit   [5:0] D0 = 6'h2a,
  parameter bit   [5:0] D1 = 6'h2a,
  parameter bit   [5:0] Dx = 6'h2a,
  parameter bit   [5:0] Dz = 6'h2a,
  parameter bit   [5:0] Db = 6'h2a,
  parameter bit   [5:0] Dh = 6'h2a
)();
endmodule

module g5_nd #(                       // NO default (override-only)
  parameter bit   [5:0] N0,
  parameter bit   [5:0] N1,
  parameter bit   [5:0] Nx,
  parameter bit   [5:0] Nz,
  parameter logic [5:0] M0,
  parameter int         K0
)();
endmodule

module g5_top;
  g5_wd #(.D0('0), .D1('1), .Dx('x), .Dz('z), .Db('b0), .Dh('h0)) u_wd ();
  g5_nd #(.N0('0), .N1('1), .Nx('x), .Nz('z), .M0('0), .K0('0))   u_nd ();
endmodule
