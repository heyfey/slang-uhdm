// § unsupportedTsInitEnd152
module mod_m;
  logic [31:0] a;
  covergroup cg(int lim, int hi);
    coverpoint a;
  endgroup
  cg cg_inst = new(3, 4) /* c */ ;
endmodule
