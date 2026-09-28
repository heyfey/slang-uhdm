// § pkgTopWidePatReplTsName210 — vw03 (v11u210 break probe): the wide pattern read by its qualified name inside ANOTHER PACKAGE's function (a member read), and nowhere else
package vp;
  typedef struct packed { logic [3:0][63:0] A; bit E; } s_t;
  localparam s_t S = '{ A: {4{64'h0}}, E: 1'b1 };
endpackage
package up;
  function automatic bit rd();
    return vp::S.E;
  endfunction
endpackage
module dut(output bit q);
  assign q = up::rd();
endmodule
