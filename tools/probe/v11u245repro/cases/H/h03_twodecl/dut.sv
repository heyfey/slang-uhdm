// § unitTdLawS245
// two $unit typedefs at the same declarator column in two files, each used by its own module
typedef logic [2:0] tri_t;
module a(input logic [2:0] i, output logic [2:0] o);
  tri_t v;
  assign v = i;
  assign o = v;
endmodule
