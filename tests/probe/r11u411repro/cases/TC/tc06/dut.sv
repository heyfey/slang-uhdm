// § typedCtorClassArgNet411
package pk;
  class B;
    int s = 2;
  endclass
  class D extends B;
    function new();
      s = 4;
    endfunction
  endclass
  function automatic B mk();
    B o;
    o = D::new;
    return o;
  endfunction
endpackage
module top();
  initial $display(pk::mk().s);
endmodule
