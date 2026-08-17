package pkI;
  typedef struct { int used; } stI_t;
  stI_t parr[4];
endpackage
module topI;
  initial pkI::parr[2].used++;
endmodule
