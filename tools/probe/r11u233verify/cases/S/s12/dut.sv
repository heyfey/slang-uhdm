// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — real, enum and struct elements in both argument forms
module dut (output logic [7:0] o1, o2, o3, o4);
  typedef enum logic [2:0] {A, B, C} e_t;
  typedef struct packed { logic [2:0] a; logic b; } s_t;
  real ra [4];
  e_t ea [3];
  s_t sa [2];
  wire [7:0] w1 = $size(ra);
  assign o1 = w1;
  wire [7:0] w2 = $size(ea, 2);
  assign o2 = w2;
  wire [7:0] w3 = $size(sa, 2);
  assign o3 = w3;
  wire [7:0] w4 = $size(ra, 1);
  assign o4 = w4;
endmodule
