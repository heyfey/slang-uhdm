// § modTdElabFoldSize249
module s1; typedef int f_t[4]; f_t x; endmodule
module s2; typedef int f_t[6]; f_t x; endmodule
module top; s1 a(); s2 b(); endmodule
