// § enumTdLastWriter214 — the home package and a $unit class in one file, a second $unit class and the module in a CRLF second file
package p;
  typedef enum logic [2:0] {A0, A1, A2, A3} st_e;
  typedef st_e ST_T;
endpackage
import p::*;
class zz_c;
  ST_T z;
endclass
