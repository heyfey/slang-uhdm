// § modDynArrTd249 (control: the law does not fire)
module top #(parameter G = 1);
  if (G) begin : g
    typedef int q_t[$];
    q_t q;
  end
endmodule
