// § memLeftReadsPatUnlocated210 — vm04 (v11u210 break probe): the computed member reads a formal member of a pattern actual AND a scalar formal, and the module reads the computed member in a localparam (a read site)
package cfgp;
  typedef struct packed { bit EN; logic [3:0][63:0] RST; } user_t;
  typedef struct packed { int unsigned WIDTH; int unsigned PER; logic [3:0][63:0] RST; } full_t;
  localparam user_t U0 = '{ EN: 1'b1, RST: {4{64'h0}} };
  function automatic full_t build(user_t U, int unsigned k);
    full_t f;
    f.RST = U.RST;
    f.WIDTH = 32 * k;
    f.PER = U.EN == 1'b1 ? (f.WIDTH / 16) : k;
    return f;
  endfunction
endpackage
module dut(output int unsigned o);
  parameter cfgp::full_t P = cfgp::build(cfgp::U0, 2);
  localparam int unsigned RD = P.PER;
  assign o = RD;
endmodule
