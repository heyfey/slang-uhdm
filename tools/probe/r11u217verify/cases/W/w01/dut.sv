// § pkgTopWidePatReplTsName210 — r11u217 w01: a wide package struct pattern with a replication member read by its QUALIFIED name inside ANOTHER package's function (v11u210 F4) and nowhere else
package vp;
  typedef struct packed { logic [3:0][63:0] A; bit E; } s_t;
  localparam s_t S = '{
      A: {4{64'h0}},
      E: 1'b1
  };
endpackage
package up;
  function automatic bit rd();
    return vp::S.E;
  endfunction
endpackage
module dut(output logic o);
  assign o = up::rd();
endmodule
