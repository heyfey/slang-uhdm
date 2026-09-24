package pk; class C; typedef struct packed { enum logic [1:0] {A, B} e; logic b; } s_t; s_t v; endclass endpackage
module m(output logic o);
  assign o = 1'b0;
endmodule
