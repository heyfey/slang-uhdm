module top #(parameter int NW = 4, parameter int LW = 32, parameter int FW = 8) (input logic [LW-1:0] rd_i [NW-1:0], input logic [1:0] off_i, output logic [FW-1:0] sel_o);
  logic [LW-1:0] cl_rdata [NW-1:0];
  logic [FW-1:0] cl_sel [NW-1:0];
  assign cl_rdata = rd_i;
  if (NW > 2) begin : g
    assign cl_sel[1] = cl_rdata[1][{off_i, 3'b0} +: FW];
  end
  assign sel_o = cl_sel[1];
endmodule
