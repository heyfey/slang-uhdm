// § defNetTypedefEndWrite134
typedef struct packed {
   logic [7:0] x;
} t;
module top(input t a[2], output logic [7:0] o);
   assign o = a[1].x;
endmodule
