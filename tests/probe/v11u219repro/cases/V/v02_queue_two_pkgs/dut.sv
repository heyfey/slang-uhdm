// § importVarElemOwnName214 — an associative array of class handles keyed by string, inherited by classes of two importing packages and a module class
package p;
  class seed_c; int s; endclass
  seed_c lookup [string];
endpackage
package q1;
  import p::*;
  class a_c; int y; endclass
endpackage
package q2;
  import p::*;
  class b_c; int z; endclass
  class c_c; int w; endclass
endpackage
module top;
  import p::*;
  class m_c; int k; endclass
  m_c mm;
endmodule
