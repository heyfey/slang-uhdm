// r11u218 decode (no law written; the face named memLeftReadSiteLoc218 in the README) — r04_body_use: the child reads it in a continuous assignment
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
  int o;
  sub #(.N(P.PER)) u1(.o(o));
endmodule
module sub #(parameter int unsigned N = 2) (output int o);
  assign o = N;
endmodule
