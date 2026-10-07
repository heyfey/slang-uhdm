// § clsTdMemberContainerPath279
program prg;
  class outer_c;
    typedef struct { int a; } orec_t;
    orec_t r;
  endclass
endprogram
module top;
  prg p();
endmodule
