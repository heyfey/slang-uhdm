// § memLeftReadsPatUnlocated210 — vm03 (v11u210 break probe): the computed member reads a NESTED formal member (U.S.N + 1), the actual a package pattern parameter
package cfgp;
  typedef struct packed { bit EN; logic [3:0] N; } sub_t;
  typedef struct packed { sub_t S; logic [3:0][63:0] RST; } user_t;
  typedef struct packed { int unsigned CNT; logic [3:0][63:0] RST; } full_t;
  localparam user_t U0 = '{ S: '{ EN: 1'b1, N: 4'd3 }, RST: {4{64'h0}} };
  function automatic full_t build(user_t U);
    full_t f;
    f.RST = U.RST;
    f.CNT = U.S.N + 1;
    return f;
  endfunction
endpackage
module dut(output int unsigned o);
  parameter cfgp::full_t P = cfgp::build(cfgp::U0);
  assign o = P.CNT;
endmodule
