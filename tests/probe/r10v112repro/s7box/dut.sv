// sub7 — the group split across THREE files and TWO packages.  Compiled twice
// with the two USE files in OPPOSITE command-line order, to test whether
// golden's base follows the design-map key (ASCII) or the file/command order.
package p7box;
  class B7 #(type Q = int, string Nm = "?"); int x7; endclass
endpackage
