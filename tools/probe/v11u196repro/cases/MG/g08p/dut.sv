// § modGenericClassListed196: control for g08, the same generic class in a package home
package pk; class item; int k; endclass endpackage
package q;
  class box #(type E = pk::item);
    E v;
    function void set(E x); v = x; endfunction
  endclass
endpackage
module sub ();
  task automatic run();
    q::box #(pk::item) b;
    b = new;
  endtask
endmodule
module top;
  sub v ();
endmodule
