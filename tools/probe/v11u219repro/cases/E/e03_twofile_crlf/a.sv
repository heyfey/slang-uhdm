// § enumTdLastWriter214 — two files with the same declarator position, the second CRLF: home package in a.sv, an importing package in b.sv
package p;
  typedef enum logic [1:0] {K0, K1, K2} k_t;
  typedef k_t ALIAS_T;
endpackage
