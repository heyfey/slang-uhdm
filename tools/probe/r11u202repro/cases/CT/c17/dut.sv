// § classSpecExprArgUnlocated202
typedef logic [3:0] nib_t;
class obj; endclass
class cfg#(type T=int, type T2=int, type T3=int);
endclass
typedef cfg#(nib_t, obj, bit [2:0]) m_misc;
module top ();
  m_misc a;
  cfg#(obj, nib_t) b;
endmodule
