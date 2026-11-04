// § clsTdMemberContainerPath279
module top;
  class outer_c;
    typedef union packed { logic [3:0] a; logic [3:0] b; } ou_t;
    ou_t u;
  endclass
  outer_c oc;
endmodule
