// A local declared with a package TYPEDEF inside a CLASS METHOD.  UVM
// (uvm_reg::get_address, `uvm_reg_addr_t addr;`) says golden points the
// variable at the TYPEDEF's OWN typespec — named `uvm_reg_addr_t`, anchored at
// the typedef — while we mint a fresh unnamed bit_typespec at the declaration.
// Same shape for a class handle (class_typespec).  Pin every host.
package pk;
  typedef bit [63:0] addr_t;
  typedef logic [7:0] byte_t;

  class Obj;
    int o;
  endclass
  typedef Obj obj_t;

  addr_t pkgVar;                     // A: package variable

  function void fPkg();
    addr_t a;                        // B: package function local
    byte_t b;
    a = 0; b = 0;
  endfunction

  function void fArg(addr_t g);      // C: package function formal
    g = 0;
  endfunction

  class User;
    addr_t prop;                     // D: class property
    obj_t hprop;
    function void m();
      addr_t c;                      // E: class method local
      byte_t d;
      obj_t e;
      addr_t dyn[];                  // E2: DYNAMIC array of the typedef
      addr_t que[$];                 // E3: queue of the typedef
      addr_t fix[4];                 // E4: fixed unpacked array
      obj_t  hdyn[];                 // E5: dynamic array of class handles
      c = 0; d = 0; e = new();
      dyn = new[2]; que.push_back(0); fix[0] = 0; hdyn = new[1];
    endfunction
    function void mArg(addr_t h);    // F: class method formal
      h = 0;
    endfunction
    extern function void mOut();
  endclass

  function void User::mOut();
    addr_t f;                        // G: out-of-body method local
    f = 0;
  endfunction
endpackage

module top;
  import pk::*;
  addr_t mv;                         // H: module variable
  function void gMod();
    addr_t i;                        // I: module function local
    i = 0;
  endfunction
  initial;
endmodule
