// r10v95 arm b11 — interface instances/modports, function formals (input/ref),
// and a package static read from a module.
package p11;
  logic [17:0] pk_vec;
  byte         pk_arr [3];
  int          pk_dyn [];
endpackage

interface bus11 #(parameter int BW = 26) ();
  logic [BW-1:0] dat;
  byte           blk [4];
  modport mp (input dat, input blk);
endinterface

module use11 (bus11.mp p);
  int u [6];
  initial begin
    u[0] = $bits(p.dat[3]);
    u[1] = $bits(p.blk[1]);
  end
endmodule

module b11;
  bus11 #(.BW(26)) bi ();
  use11 uu (.p(bi));
  int r [12];
  function automatic int f11(input byte fa [3], ref logic [22:0] fv);
    return $bits(fa[1]) + $bits(fv[4]) + $bits(fv[9:2]);
  endfunction
  byte  la [3];
  logic [22:0] lv;
  initial begin
    r[0] = $bits(bi.dat[2]);
    r[1] = $bits(bi.blk[0]);
    r[2] = f11(la, lv);
    r[3] = $bits(p11::pk_vec[1]);
    r[4] = $bits(p11::pk_arr[2]);
    r[5] = $bits(p11::pk_dyn[0]);
  end
endmodule
