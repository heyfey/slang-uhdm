// § sizeDimOvrFileAtDim212 — the instantiating module in another file overrides the size with a literal (Rggen block_0.sv)
module top(input logic clk);
  rif ifs[3]();
  child #(.REGISTERS(3)) u (.i_clk(clk), .register_if(ifs));
endmodule
