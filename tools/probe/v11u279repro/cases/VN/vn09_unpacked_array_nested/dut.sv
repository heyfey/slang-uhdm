// § clsTdMemberContainerPath279
package px;
  class outer_c;
    class inner_c;
      typedef int arr_t [2];
    endclass
    function void f(); inner_c::arr_t v; v[0] = 1; endfunction
  endclass
endpackage
module top;
  px::outer_c oc;
  initial oc = new();
endmodule
