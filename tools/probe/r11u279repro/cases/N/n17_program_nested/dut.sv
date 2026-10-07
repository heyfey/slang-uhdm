// § clsTdMemberContainerPath279
program prg;
  class outer_c;
    class inner_c;
      typedef struct { int a; } irec_t;
    endclass
  endclass
endprogram
module top;
  prg p();
endmodule
