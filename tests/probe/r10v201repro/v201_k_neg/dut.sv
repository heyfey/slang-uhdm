// v201 arm K — NEGATIVE controls that must not move: a module's OWN
// reference-defaulted parameter (never imported), and a package's own.
package p201vk;
  parameter K_A = 13;
endpackage
module m201vk;
  parameter K_OWN  = 13;
  parameter K_OWNR = K_OWN;
  parameter K_PKGR = p201vk::K_A;
endmodule
