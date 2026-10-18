// § builtinClassElemNotInClass404v
package pk;
  class C;
    function void f();
      process p[2];
      semaphore s[];
      $display($size(p), s.size());
    endfunction
  endclass
  task automatic pt(int n);
    process q[] = new[n];
    $display(q.size());
  endtask
endpackage
module top;
  initial begin pk::C c = new; c.f(); pk::pt(2); end
endmodule
