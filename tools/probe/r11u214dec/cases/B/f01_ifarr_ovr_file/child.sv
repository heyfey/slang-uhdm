// § sizeDimOvrFileAtDim212 — an interface-array port sized by an overridden parameter (Rggen rggen_apb_adapter.sv:18 register_if[REGISTERS])
module child #(
  parameter int REGISTERS = 1
)(
  input  logic   i_clk,
  rif.host       register_if[REGISTERS]
);
  for (genvar i = 0; i < REGISTERS; i++) begin : g
    assign register_if[i].v = i_clk;
  end
endmodule
