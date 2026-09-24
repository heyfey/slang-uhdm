package mp;
  typedef struct packed { logic [3:0] m1; logic [3:0] m2; } st_t;
endpackage
module m1 #(parameter bit EN = 1) (input mp::st_t s, output logic y);
  assign y = EN ? s.m1[0] : 1'b0;
endmodule
