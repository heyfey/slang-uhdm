// § unsupportedTsInitEnd152
module mod_m;
  logic [31:0] a;
  covergroup cg;
    coverpoint a;
  endgroup
  if (1) begin : g
    cg cg_inst = new;
  end
endmodule
