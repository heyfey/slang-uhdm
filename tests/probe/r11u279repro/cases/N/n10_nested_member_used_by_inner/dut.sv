// § clsTdMemberContainerPath279
package px;
  class outer_c;
    class inner_c;
      typedef struct { int a; } irec_t;
      irec_t r;
    endclass
    inner_c ic;
  endclass
endpackage
module top;
  px::outer_c oc;
  initial oc = new();
endmodule
