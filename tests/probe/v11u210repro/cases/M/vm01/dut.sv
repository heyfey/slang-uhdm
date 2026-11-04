// § memLeftReadsPatUnlocated210 — vm01 (v11u210 break probe): the pattern actual is a localparam of the MODULE (not a package); the computed member reads the formal member in a ternary
package cfgp;
  typedef struct packed { bit EN; logic [3:0][63:0] RST; } user_t;
  typedef struct packed { int unsigned WIDTH; int unsigned PER; logic [3:0][63:0] RST; } full_t;
  function automatic full_t build(user_t U);
    full_t f;
    f.RST = U.RST;
    f.WIDTH = 32;
    f.PER = U.EN == 1'b1 ? (f.WIDTH / 16) : 1;
    return f;
  endfunction
endpackage
module dut(output int unsigned o);
  localparam cfgp::user_t UA = '{ EN: 1'b1, RST: {4{64'h0}} };
  parameter cfgp::full_t P = cfgp::build(UA);
  assign o = P.PER;
endmodule
