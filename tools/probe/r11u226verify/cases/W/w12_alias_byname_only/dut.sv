// § enumTdLastWriter214 § enumPkgWriterImportsType219 — two packages import only the alias by name, one of them the last package by dependency order; a module imports the home package
package p;
  typedef enum logic [2:0] {K0, K1, K2} k_e;
  typedef k_e K_T;
endpackage
package bq;
  import p::K_T;
  localparam int BN = 2;
endpackage
package aq;
  import p::K_T;
  localparam int AN = 3;
endpackage
module top(output int o);
  import p::*;
  k_e s = K2;
  assign o = int'(s) + aq::AN + bq::BN;
endmodule
