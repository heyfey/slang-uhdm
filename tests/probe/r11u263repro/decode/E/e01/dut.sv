// § genCaEnumBindsSelectOnly22 (decode only, ground A: Earlgrey default #395727, ExprEmit binds a fresh enum_const without a location where golden binds the located package constant)
package ip;
  typedef enum logic [1:0] {
    WB_INSTR_LOAD,
    WB_INSTR_STORE,
    WB_INSTR_OTHER
  } wb_instr_type_e;
endpackage
module wb import ip::*; #(parameter bit WritebackStage = 1'b1) (
  input logic clk, input wb_instr_type_e t_i, input logic v_i, output logic o);
  if (WritebackStage) begin : g_writeback_stage
    wb_instr_type_e wb_instr_type_q;
    logic wb_done;
    always_ff @(posedge clk) wb_instr_type_q <= t_i;
    assign wb_done = (wb_instr_type_q == WB_INSTR_OTHER) | v_i;
    assign o = wb_done;
  end else begin : g_bypass
    assign o = v_i;
  end
endmodule
module top(input logic clk, input ip::wb_instr_type_e t, input logic v, output logic o);
  wb u_wb(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
