// § unitTdLawS245
// decode (ground A): a module parameter and a localparam typed by $unit typedefs
typedef int ui_t;
typedef logic [7:0] ub_t;
module top;
  parameter ui_t P = 3;
  localparam ub_t L = 8'h5;
  ub_t v;
  assign v = L + P;
endmodule
