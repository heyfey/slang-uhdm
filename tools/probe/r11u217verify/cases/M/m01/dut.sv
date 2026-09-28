// § memLeftReadsPatUnlocated210 — r11u217 m01: NESTED builder calls: the builder reads the pattern formal's member through a helper function call (`half(U.EN)`) and through a second builder, the actual a pattern parameter of another package
package cfgp;
  typedef struct packed { bit EN; logic [3:0] K; } user_t;
  typedef struct packed { int unsigned WIDTH; int unsigned PER; int unsigned Q; } full_t;
endpackage
package valp;
  localparam cfgp::user_t ucfg = '{ EN: 1'b1, K: 4'd6 };
endpackage
package bldp;
  function automatic int unsigned half(bit e, int unsigned w);
    return e ? w / 2 : w;
  endfunction
  function automatic int unsigned inner(cfgp::user_t U);
    return U.K + 1;
  endfunction
  function automatic cfgp::full_t build(cfgp::user_t U);
    cfgp::full_t f;
    f.WIDTH = 32;
    f.PER = half(U.EN, f.WIDTH);
    f.Q = inner(U);
    return f;
  endfunction
endpackage
module dut(output int o);
  localparam cfgp::full_t P = bldp::build(valp::ucfg);
  assign o = P.PER;
endmodule
