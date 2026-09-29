// § enumTdLastWriter214 § enumClsWriterUnitScopeOnly219 — $unit classes in two files, one from an included header, the last by name writes
package p;
  typedef enum logic [1:0] {M0, M1} m_t;
  typedef m_t ALIAS_T;
endpackage
import p::*;
class aa_c;
  ALIAS_T w;
endclass
`include "hdr.svh"
