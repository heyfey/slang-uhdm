// A local whose declared type is a PARAMETERIZED class SPECIALIZATION.
// UVM (uvm_reg::add_hdl_path, `uvm_queue #(uvm_hdl_path_concat) paths = ...`)
// says golden gives the variable's ref_typespec NO actual at all, where we
// emit an unnamed class_typespec.  Pin the axes: specialization vs bare name,
// class-method local vs package-function local vs class property vs formal.
package pk;
  class Item;
    int i;
  endclass

  class Q #(type T = int);
    T q;
  endclass

  class User;
    Q #(Item) prop;                       // A: class PROPERTY, specialized
    Q #(Item) propInit = new();           // B: property with initializer
    function void mSpec();
      Q #(Item) a;                        // C: method local, specialized
      Q #(Item) b = new();                // D: method local, spec + init
      Item c;                             // E: method local, bare
      a = new(); b = null; c = new();
    endfunction
    function void mArg(Q #(Item) g);      // F: method FORMAL, specialized
      g = null;
    endfunction
  endclass

  function void fSpec();
    Q #(Item) d;                          // G: package function local
    d = new();
  endfunction
endpackage

module top;
  import pk::*;
  function void gSpec();
    pk::Q #(pk::Item) e;                  // H: module function local, scoped
    e = new();
  endfunction
  pk::Q #(pk::Item) f;                    // I: module-scope variable
  initial;
endmodule
