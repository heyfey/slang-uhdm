// r11u33 grid arm g4_keep33 — THE KEEP/FOLD DECISION (K5's two directions).
//
// A struct-typed PARAMETER's member read (`Cfg.X`) as a range bound, written
// at every site, against the SAME read reached through an INTERFACE INSTANCE
// (`s.CFG.X`) and against a plain parameter read at the same sites.  Golden
// keeps an operation at some of these and folds at others; the cell grid is
// what says which.
package g4pk33;
  typedef struct packed {
    int unsigned X;
    int unsigned Y;
  } cfg_t;
  parameter cfg_t DEF = '{X: 32'd64, Y: 32'd32};
endpackage

interface g4if33 #(parameter g4pk33::cfg_t CFG = g4pk33::DEF) ();
  logic [CFG.X-1:0] if_dat;
  modport m (input if_dat);
endinterface

// The corpus shape (`iface_param_2level`): the interface arrives as a MODPORT
// PORT and its struct parameter member is the child's override actual.  A
// LOCAL interface instance used the same way is REFUSED by slang outright
// ("reference to 'CFG' by hierarchical name is not allowed in a constant
// expression"), so that cell is not on this grid — an arm whose compile fails
// teaches error recovery, not golden.
module g4wrap33 (input logic clk, g4if33.m s, input logic [31:0] wdt);
  g4leaf33 #(.SD(s.CFG.X)) u_inner (.clk(clk), .wdt(wdt[7:0]));
endmodule

module g4leaf33 #(parameter int unsigned SD = 8)
                (input logic clk, input logic [SD-1:0] wdt);
  logic [SD-1:0] r_dat;      // ELAB: the override actual substitutes here
  always_ff @(posedge clk) r_dat <= wdt;
endmodule

module g4_keep33 #(
    parameter g4pk33::cfg_t Cfg = g4pk33::DEF,
    parameter int unsigned  PN  = 16
) (
    input  logic                clk,
    input  logic [Cfg.X-1:0]    i_cfg,   // PORT, struct-param member
    input  logic [PN-1:0]       i_pn,    // PORT, plain param
    output logic [Cfg.X-1:0]    o_cfg
);
  // body VARIABLE
  logic [Cfg.X-1:0] v_cfg;
  logic [PN-1:0]    v_pn;
  logic c_arr [Cfg.X-1:1];

  // TYPEDEF packed dims — the DEF-side no-reduce face
  typedef logic [Cfg.X-1:0] t_cfg;
  typedef logic [PN-1:0]    t_pn;
  t_cfg y_cfg;
  t_pn  y_pn;

  // `localparam type` whose struct members carry the same bound
  localparam type it_t = struct packed {
    logic [Cfg.X-1:0] sx;
    logic [PN-1:0]    sp;
  };
  it_t y_it;

  // an INTERFACE instance whose own parameter is a struct, reached through a
  // MODPORT PORT by the wrapper (the corpus shape)
  g4if33 s();
  g4wrap33 u_if (.clk(clk), .s(s.m), .wdt('0));
  // a child whose parameter is OVERRIDDEN by a module-struct member read
  g4leaf33 #(.SD(Cfg.X)) u_md (.clk(clk), .wdt('0));
  // ...and by a plain parameter
  g4leaf33 #(.SD(PN)) u_pn (.clk(clk), .wdt('0));

  assign o_cfg = v_cfg;
  always_ff @(posedge clk) v_pn <= '0;
endmodule
