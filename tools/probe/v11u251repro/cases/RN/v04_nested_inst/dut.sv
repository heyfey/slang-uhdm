// § regTdArrElabIsNet251 (reg typedef variable in a child instance two levels down)
typedef reg r_t [2];
module leaf; r_t m; endmodule
module mid; leaf u1(); leaf u2(); endmodule
module top; mid a(); endmodule
