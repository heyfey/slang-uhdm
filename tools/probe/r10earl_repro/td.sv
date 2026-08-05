// r10earl7 witness td — DEF-VIEW GEN-BLOCK port connection whose actual is an
// OPERATION over genvar-indexed bit-selects.
// Census head (3 AllModules entries: ibex_core, ibex_cs_registers,
// rv_core_ibex):
//   operation '' ibex_cs_registers.sv:950:22  vs  var_select
//   'mhpmcounter_incr' :950:22
// i.e. golden's def-view High_conn for
//   .counter_inc_i(mhpmcounter_incr[cnt+3] & ~mcountinhibit[cnt+3])
// inside `for (genvar cnt=0; ...) begin : gen_cntrs` is the `&` OPERATION;
// we emit only its left operand.
module tdsub #(
  parameter int W = 8
) (
  input  logic         a_i,
  input  logic         b_i,
  input  logic [W-1:0] v_i,
  output logic         z_o
);
  assign z_o = a_i ^ b_i ^ (|v_i);
endmodule

module td #(
  parameter int N = 4
) (
  input  logic [15:0] inc_i,
  input  logic [15:0] inh_i,
  input  logic [7:0]  val_i,
  output logic [3:0]  z_o
);

  for (genvar c = 0; c < N; c++) begin : gen_cntrs
    tdsub #(
      .W(8)
    ) u_sub (
      .a_i(inc_i[c+3] & ~inh_i[c+3]),   // SUBJECT — operation over selects
      .b_i(inc_i[c+3]),                 // bare genvar-indexed select
      .v_i(val_i),                      // plain ref
      .z_o(z_o[c])
    );
  end

endmodule
