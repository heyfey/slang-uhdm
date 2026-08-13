// VERIFIER arm v2 — the SCOPE axis the implementer's grid never varied:
// class in a MODULE, NESTED class, class in an INTERFACE, and a PARAMETERIZED
// class with TWO specializations (does each class_defn get the constant?).
package p2v2;
  class holder;
    class inner;                 // NESTED class
      time  s01_t = 5ns;
      chandle s02_c = null;
      int   s03_u = $urandom;
    endclass
    time s04_t = 7ns;
  endclass
  class gen #(int W = 8);
    time  s05_t = 3ns;
    logic [W-1:0] s06_w = 5ns;   // width DEPENDS on the parameter
    chandle s07_c = null;
  endclass
  class user;
    gen #(4)  g4;
    gen #(16) g16;
  endclass
endpackage

module mtop2;
  class inmod;                   // class declared in a MODULE
    time    s08_t = 9200s;
    chandle s09_c = null;
    int     s10_u = $urandom;
  endclass
endmodule

interface iface2;
  class iniface;                 // class declared in an INTERFACE
    time    s11_t = 4ns;
    chandle s12_c = null;
  endclass
endinterface

module iftop2; iface2 i2(); endmodule
