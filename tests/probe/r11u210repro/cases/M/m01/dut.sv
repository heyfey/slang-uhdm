// § memLeftReadsPatUnlocated210 — m01: the computed member reads a formal member in a ternary, the actual a pattern parameter of another package (FuncStructValSimple's shape)
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
    f.PER = U.EN == 1'b1 ? (f.WIDTH / 16) : 1;
    return f;
  endfunction
endpackage
module dut();
  parameter cfgp::full_t P = bldp::build(
        valp::ucfg);
endmodule
