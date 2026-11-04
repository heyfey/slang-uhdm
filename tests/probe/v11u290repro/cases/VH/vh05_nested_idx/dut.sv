// § elabCaBaseSelRefIdxAtElem290
module top(input logic [1:0] p, q, output logic o);
typedef struct packed { logic a; logic b; } s_t;
typedef struct packed { s_t [3:0] arr; } w_t;
w_t w [4];
assign o = ~w[p].arr[q].a;
endmodule
