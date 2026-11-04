// § unitArrTd245
// a $unit fixed-array typedef sized by a $unit localparam
localparam N = 4;
typedef logic [3:0] arr_t [N];
module top(input logic [1:0] a, input logic [3:0] d, output logic [3:0] q);
  arr_t m;
  assign m[0] = d;
  assign m[1] = d;
  assign m[2] = d;
  assign m[3] = d;
  assign q = m[a];
endmodule
