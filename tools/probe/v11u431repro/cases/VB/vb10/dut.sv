// § unitParamNameBindsDesign431 (a struct-typed variable with the $unit name, member read)
localparam CF = 2;
typedef struct packed { logic a; logic b; } s_t;
module top(input [1:0] c, output logic y);
s_t CF;
assign CF = c;
always_comb y = CF.a;
endmodule
