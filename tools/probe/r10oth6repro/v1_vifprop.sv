// r10oth6 arm 1 -- VIRTUAL INTERFACE class properties, every spelling.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
interface v_if(input bit clk);
  logic       a;
  logic [7:0] b;
  clocking cb @(posedge clk);
    default input #1 output #1;
    output a;
  endclocking
  modport IP(clocking cb, output a, input clk);
  modport OP(clocking cb, input clk);
endinterface

// c1 -- THE WITNESS SHAPE: modport-selected virtual interface property.
class c1_modport;
  virtual v_if.IP  vi;
  int              after;
endclass

// c2 -- the MAJORITY spelling: NO modport selector.
class c2_bare;
  virtual v_if  vi;
  int           after;
endclass

// c3 -- explicit `interface` keyword, no modport.
class c3_kw;
  virtual interface v_if  vi;
  int                     after;
endclass

// c4 -- explicit `interface` keyword WITH a modport.
class c4_kwmodport;
  virtual interface v_if.IP  vi;
  int                        after;
endclass

// c5 -- TWO properties of the SAME interface type (do they share anything?).
class c5_two;
  virtual v_if.IP  vi1;
  virtual v_if.IP  vi2;
  int              after;
endclass

// c6 -- CONSTRUCTOR ARGUMENT ONLY: no property of interface type at all.
class c6_argonly;
  int          after;
  function new(virtual v_if.IP  vin);
    after = 0;
  endfunction
endclass

// c7 -- BOTH: property AND constructor argument, as SVSwitch has it.
class c7_both;
  virtual v_if.IP  vi;
  int              after;
  function new(virtual v_if.IP  vin);
    this.vi = vin;
  endfunction
endclass

// c8 -- qualifiers: local / protected / static.
class c8_quals;
  local     virtual v_if.IP  vloc;
  protected virtual v_if.IP  vprot;
  static    virtual v_if.IP  vstat;
  int                        after;
endclass

// c9 -- TWO DECLARATORS in ONE declaration.
class c9_twodecl;
  virtual v_if.IP  vx, vy;
  int              after;
endclass

// c10 -- an UNPACKED ARRAY of virtual interfaces.
class c10_arr;
  virtual v_if.IP  va[4];
  int              after;
endclass

// c11 -- an explicit `= null` initializer.
class c11_init;
  virtual v_if.IP  vi = null;
  int              after;
endclass

// c12 -- ORDERING control: an int BEFORE the virtual interface property.
class c12_order;
  int              pre_i;
  virtual v_if.IP  vi;
  int              after;
endclass

module top;
  bit clk;
  v_if u(clk);
  // m1 -- the same declaration as a MODULE variable, not a class property.
  virtual v_if.IP  mvi;
  virtual v_if     mvb;
  // m2 -- the explicit-`interface`-keyword spellings, for the TYPESPEC SPAN:
  //       does the span start at the interface NAME or at `interface`?
  virtual interface v_if     mvk;
  virtual interface v_if.IP  mvkm;
  c1_modport h1;
endmodule
