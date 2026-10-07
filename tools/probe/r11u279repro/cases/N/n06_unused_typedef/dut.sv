// § clsTdMemberContainerPath279
package px;
  class outer_c;
    class inner_c;
      typedef struct { int a; } irec_t;
    endclass
  endclass
endpackage
module top;
  px::outer_c oc;
  initial oc = new();
endmodule
