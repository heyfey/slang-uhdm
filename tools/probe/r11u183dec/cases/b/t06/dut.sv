package p;
class base;
  function new(string name, base parent); endfunction
endclass
class wrapper; endclass
class reg1 #(type T=base, string Tname="<unknown>") extends wrapper;
  virtual function base create_component (string name, base parent);
    T obj;
    obj = new(name, parent);
    return obj;
  endfunction
endclass
endpackage
module top; endmodule
