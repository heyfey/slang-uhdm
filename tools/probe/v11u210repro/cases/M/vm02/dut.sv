// § memLeftReadsPatUnlocated210 — vm02 (v11u210 break probe): the computed member reads the formal member through $clog2 and a comparison chain, the pattern actual qualified from a package, and the result member read in a generate condition and a port width
package cfgp;
  typedef struct packed { int unsigned W; bit EN; } user_t;
  typedef struct packed { int unsigned W; int unsigned LW; int unsigned PER; } full_t;
  localparam user_t U0 = '{ W: 64, EN: 1'b1 };
endpackage
package bldp;
  function automatic cfgp::full_t build(cfgp::user_t U);
    cfgp::full_t f;
    f.W = U.W;
    f.LW = $clog2(U.W);
    f.PER = (U.EN && U.W > 32) ? U.W / 32 : 1;
    return f;
  endfunction
endpackage
module dut #(parameter cfgp::full_t P = bldp::build(cfgp::U0)) (output logic [P.LW-1:0] o);
  if (P.PER > 1) begin : g
    assign o = '1;
  end else begin : h
    assign o = '0;
  end
endmodule
