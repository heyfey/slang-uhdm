// § hpTrailIpsNamesByPath218
typedef struct packed { logic [31:0] a_data; logic v; } tl_t;
module sub(input logic [7:0] d, output logic [7:0] q); assign q = d; endmodule
module top(input tl_t tl, output logic [1:0][7:0] o);
  for (genvar g = 0; g < 2; g++) begin : gen
    sub u(.d(tl.a_data[8*g +: 8]), .q(o[g]));
  end
endmodule
