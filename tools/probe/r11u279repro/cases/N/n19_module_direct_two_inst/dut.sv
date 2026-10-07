// § clsTdMemberContainerPath279
module sub;
  class outer_c;
    typedef struct { int a; } orec_t;
    orec_t r;
  endclass
  outer_c oc;
endmodule
module top;
  sub s1();
  sub s2();
endmodule
