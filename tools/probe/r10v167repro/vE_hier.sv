// r10v167 arm E - HIERARCHICAL and INTERFACE method calls, and the pair
// (fully written / defaulted) inside ONE method, with 1-3 instances.
interface ie167;
  int q;
  function int ifn167(int a, int b = 51, int c = 52);
    return a + b + c;
  endfunction
  task itk167(int a, int b = 53);
    q = a + b;
  endtask
endinterface

module leaf167 (ie167 vif);
  int r;
  function int lf167(int a, int b = 61, int c = 62);
    return a + b + c;
  endfunction
  class shE167 #(type T167 = int);
    int rr;
    task goE();
      // interface method call through the port
      rr = vif.ifn167(1);
      rr = vif.ifn167(T167::nm167);
      rr = vif.ifn167(.a(T167::nm167), .c(9));
      vif.itk167(T167::nm167);
      // hierarchical call up to the top
      rr = top167.hf167(1);
      rr = top167.hf167(T167::nm167);
      rr = top167.hf167(.a(T167::nm167), .c(9));
      // the pair, one method
      rr = lf167(1, 61, 62);
      rr = lf167(1);
      rr = lf167(T167::nm167, 61, 62);
      rr = lf167(T167::nm167);
    endtask
  endclass
endmodule

module top167;
  ie167 iv();
  function int hf167(int a, int b = 71, int c = 72);
    return a + b + c;
  endfunction
  leaf167 l1 (.vif(iv));
  leaf167 l2 (.vif(iv));
  leaf167 l3 (.vif(iv));
endmodule
