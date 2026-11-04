// § decode E: e01 with only the static associative-array property written T
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=e_t);
    protected static T map[string];
  endclass
endpackage
