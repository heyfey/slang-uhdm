// § memLeftReadsPatUnlocated210 — m03: the caller a package localparam read by a module
package cfgp;
  typedef struct packed {
    bit                 EN;
    logic [7:0][63:0]   RST;
  } user_t;
  typedef struct packed {
    int unsigned WIDTH;
    int unsigned PER;
    logic [7:0][63:0]   RST;
  } full_t;
endpackage
package valp;
  localparam EnOn = 1;
  localparam cfgp::user_t ucfg = '{
      EN: bit'(EnOn),
      RST: {8{64'h0}}
  };
endpackage
package bldp;
  function automatic cfgp::full_t build(cfgp::user_t U);
    cfgp::full_t f;
    f.RST = U.RST;
    f.WIDTH = 32;
    f.PER = U.EN ? 4 : 2;
    return f;
  endfunction
endpackage
package holdp;
  localparam cfgp::full_t P = bldp::build(valp::ucfg);
endpackage
module dut(output int o);
  assign o = holdp::P.PER;
endmodule
