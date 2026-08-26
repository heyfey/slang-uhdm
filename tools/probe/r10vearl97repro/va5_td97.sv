// v97 va5 -- TYPEDEF CHAINS, PACKAGE TYPEDEFS AND TYPE PARAMETERS as the
// declared type of a cast-width target.  Each is a form whose signedness our
// declaration typespec must derive independently of golden's; if any of them
// derives it differently, MIRRORING it at the cast site turns an accidental
// agreement into a disagreement.
package pva5;
  typedef int          ki97;
  typedef int unsigned ku97;
  typedef ku97         ku2_97;      // chained typedef
  parameter int PB = 8;
endpackage
module topva5;
  logic [31:0] o, o2;
  subva5 #(.InW(8)) u_s(.o(o));
  tva5 #(.T(int))          u_t1(.o());
  tva5 #(.T(int unsigned)) u_t2(.o());
endmodule
module subva5 import pva5::*; #(parameter int InW = 32) (output logic [31:0] o);
  typedef ki97 loc_i97;             // local alias of a package typedef
  logic [3:0] m;
  localparam pva5::ki97 W_PKI = $clog2(InW + 1);
  localparam pva5::ku97 W_PKU = $clog2(InW + 2);
  localparam ku2_97     W_CHU = $clog2(InW + 3);
  localparam loc_i97    W_LOC = $clog2(InW + 4);
  assign o = 32'(W_PKI'(m)) + 32'(W_PKU'(m)) + 32'(W_CHU'(m)) + 32'(W_LOC'(m));
endmodule
module tva5 #(parameter type T = int) (output logic [31:0] o);
  logic [3:0] m;
  localparam T W_TP = 5 + 1;        // computed, type from a type parameter
  assign o = 32'(W_TP'(m));
endmodule
