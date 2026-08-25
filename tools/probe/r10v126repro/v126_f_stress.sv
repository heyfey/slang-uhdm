// r10v126 arm F - CRASH / SYMMETRY stress.  Fixed-size unpacked keyword arrays
// in the least ordinary legal homes: a constructor, a virtual/pure-virtual
// method, a parameterised class extending another, a program block, a static
// method, a task with a default-valued formal, a class nested in a class, and
// a method reached only through a virtual interface.
package pk_str126v;
  virtual class Base126v #(type T126v = int, int N126v = 2);
    pure virtual function int hook126v();
    function new();
      string  ctStr126v [3];
      chandle ctHnd126v [2];
      time    ctTim126v [4];
      event   ctEvt126v [2];
      ctStr126v[2] = "c"; ctHnd126v[1] = null; ctTim126v[3] = 1;
    endfunction
    static function int stat126v();
      shortreal stSrl126v [5];
      longint   stLng126v [3];
      stSrl126v[4] = 1.5; stLng126v[2] = 64'd2;
      return 0;
    endfunction
  endclass

  class Derived126v #(int N126v = 3) extends Base126v #(string, N126v);
    class Inner126v;
      task innerT126v();
        string  inStr126v [4];
        integer inInt126v [2];
        inStr126v[3] = "i"; inInt126v[1] = 5;
      endtask
    endclass
    virtual function int hook126v();
      string  hkStr126v [N126v];
      byte    hkByt126v [2];
      hkStr126v[0] = "h"; hkByt126v[1] = 8'd1;
      return 0;
    endfunction
    task defArg126v(int k126v = 3);
      real   daRea126v [2];
      string daStr126v [5];
      daRea126v[1] = 1.5; daStr126v[4] = "d";
    endtask
  endclass
endpackage

interface class ic126v;
  pure virtual function int icf126v();
endclass

program prog126v;
  task ptsk126v();
    string  prStr126v [2];
    shortint prShi126v [3];
    prStr126v[1] = "p"; prShi126v[2] = 16'd4;
  endtask
  initial ptsk126v();
endprogram

module top126v;
  pk_str126v::Derived126v #(4) d126v;
  initial begin
    d126v = new();
    void'(d126v.hook126v());
    d126v.defArg126v();
    void'(pk_str126v::Derived126v#(4)::stat126v());
  end
endmodule
