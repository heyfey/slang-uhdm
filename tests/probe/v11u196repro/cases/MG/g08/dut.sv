// § modGenericClassListed196 § modGenericHandleBare196: a module generic class with a class-typed type parameter defaulted to a package class, a handle in a task
package pk; class item; int k; endclass endpackage
module sub ();
  class box #(type E = pk::item);
    E v;
    function void set(E x); v = x; endfunction
  endclass
  task automatic run();
    box #(pk::item) b;
    b = new;
  endtask
endmodule
module top;
  sub v ();
endmodule
