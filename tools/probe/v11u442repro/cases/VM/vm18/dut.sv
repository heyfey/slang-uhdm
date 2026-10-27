// § modDynArrClsTdElemClassVar442
class C;
endclass
module top;
  typedef C c_t;
  initial begin
    c_t q [$];
    q.push_back(null);
  end
endmodule
