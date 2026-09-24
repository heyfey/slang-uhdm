module top #(parameter int NW = 4, parameter int LW = 32, parameter int FW = 8) (input logic [LW-1:0] rd_i [NW-1:0], input logic [1:0] off_i, output logic [FW-1:0] sel_o);
  logic [LW-1:0] cl_rdata [NW-1:0];
  logic [FW-1:0] cl_sel [NW-1:0];
  assign cl_rdata = rd_i;
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar j = 0; j < 2; j++) begin : h
      assign cl_sel[i*2+j] = cl_rdata[i*2+j][{off_i, 3'b0} +: FW];
    end
  end
  assign sel_o = cl_sel[0];
endmodule
