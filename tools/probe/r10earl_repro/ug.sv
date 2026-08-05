// r10earl9 witness G — two more shapes the DEF-VIEW gen-block instantiation's
// port-actual dispatcher (ModuleEmit, § genConnOperatorActualFirst's chain)
// has no arm for, so both fall to the final else and come out as ONE ref_obj
// NAMED WITH THE ACTUAL'S OWN SOURCE TEXT:
//   ibex_icache.sv:311  `.wmask_i ({TAG_SIZE_ECC{1'b1}})`  a REPLICATION
//   pinmux.sv:240       `.wkup_mode_i ( wkup_mode_e'(...) )` a TYPE CAST
// Golden calls both `operation` at the actual's own span.
package ugp;
  typedef enum logic [1:0] { A0, A1, A2 } mode_e;
endpackage

module ugsub #(
  parameter int W = 4
) (
  input  logic [W-1:0]  wmask_i,
  input  ugp::mode_e    mode_i,
  input  logic [W-1:0]  cat_i,
  output logic          o
);
  assign o = ^wmask_i ^ ^mode_i ^ ^cat_i;
endmodule

module ug
  import ugp::*;
#(
  parameter int NumWays = 2,
  parameter int TAG_W   = 4
) (
  input  logic [1:0] mode_raw_i,
  output logic [NumWays-1:0] o
);
  for (genvar way = 0; way < NumWays; way++) begin : gen_rams
    ugsub #(
      .W (TAG_W)
    ) u_sub (
      // row A — a REPLICATION actual
      .wmask_i ({TAG_W{1'b1}}),
      // row B — a TYPE CAST actual
      .mode_i  (mode_e'(mode_raw_i)),
      // row C — a CONCAT actual (control: already has an arm)
      .cat_i   ({2'b10, mode_raw_i}),
      .o       (o[way])
    );
  end
endmodule
