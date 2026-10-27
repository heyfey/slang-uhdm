// § modDynArrClsTdElemClassVar442
class C;
endclass
typedef C uc_t;
module top;
  function automatic int f();
    uc_t q [$];
    return q.size();
  endfunction
  task automatic t();
    uc_t d [];
  endtask
endmodule
