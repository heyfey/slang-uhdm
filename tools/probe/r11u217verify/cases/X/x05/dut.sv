// § tfItemInitLocalAtType209 § pkgTopWidePatReplTsName210 — r11u217 x05: a paren-less package function whose local is initialized by a qualified read of a wide package struct pattern with a replication member
package vp;
  typedef struct packed { logic [3:0][63:0] A; bit E; } s_t;
  localparam s_t S = '{
      A: {4{64'h0}},
      E: 1'b1
  };
endpackage
package up;
  function bit rd;
    vp::s_t loc = vp::S;
    bit e = vp::S.E;
    return loc.E & e;
  endfunction
endpackage
module dut(output logic o, output logic p);
  assign o = up::rd();
  assign p = vp::S.E;
endmodule
