// § unsupportedTsInitEnd152
module mod_m;
  logic [31:0] a;
  covergroup cg(int lim);
    coverpoint a;
  endgroup
  cg c1 = new(3), c2 = new(4);
endmodule
