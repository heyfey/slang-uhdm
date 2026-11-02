// § unitImpTransitiveTds464 (the packages in another file)
package a;
  typedef logic [3:0] a_t;
endpackage
package m;
  import a::*;
  typedef logic [2:0] m_t;
endpackage
