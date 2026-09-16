// ROAD D, the corpus SHAPE: the package struct localparam is READ through a
// module parameter of the same struct type (StructParamFuncBodyFieldCompare's
// `parameter cfg_pkg::cfg_t Cfg = cfg_pkg::build_config(cfg_pkg::Base)` reads
// `Base` the same way).  This is the arm whose HEAD is the elaborated pattern
// element's SIZE, not the pattern operation's missing typespec.
package cfg_pkg;
  typedef struct packed {
    int unsigned XLEN;
    int unsigned NrRules;
  } user_cfg_t;
  localparam user_cfg_t Base = '{ XLEN: unsigned'(64), NrRules: unsigned'(2) };
endpackage
module dut #(parameter cfg_pkg::user_cfg_t C = cfg_pkg::Base)
           (output logic [31:0] o);
  assign o = C.XLEN | C.NrRules;
endmodule
