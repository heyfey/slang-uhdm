// § pkgArrTdImportClone250
package a;
  typedef byte b_t[2];
  typedef int q_t[$];
  typedef bit [1:0] s_t[string];
endpackage
package p;
  import a::*;
  int k;
endpackage
module top;
  import p::*;
  int m;
endmodule
